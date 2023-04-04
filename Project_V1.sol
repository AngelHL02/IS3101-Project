// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import required packages
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol"; 

contract medical{

/*
    For testing:
    patient_addr: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    hospital: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

    Others: 
    0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    0xdD870fA1b7C4700F2BD7f44238821C26f7392148
*/

//--------------------------- settings---------------------------

    //Class: patient
    struct Patient{
        string name;
        uint8 id;
        //uint acc_activateTime; 
        bool eligible; //default is false
        uint8 stage_acc; //from enum StageAcc
        uint8 stage_service; //from enum Stage
    }

    address[] registerList;

    address public admin;
    //address payable public patient_addr;
    address payable public hospital;

    //mapping (address => uint) public balances; //Keep check of user's balance
    mapping (address => Patient) patient; 

    uint public startTime;
    
    enum StageAcc {Init, Acc_Activated}
    enum StageServiceRequest {Init,Requested,Pending,Confirmed,Reject}

    //initialize the initial status of stages
    StageAcc public stageAcc = StageAcc.Init; //0
    StageServiceRequest public stageService = StageServiceRequest.Init; //0

/*  Old constructor
    constructor(address payable _patient, address payable _hospital){
        admin = msg.sender;
        patient_addr = _patient;
        hospital = _hospital; //Record the hospital's address

        startTime = block.timestamp; //Start time of the whole process
    }
*/
    constructor(address payable _hospital){
        admin = msg.sender;
        //patient_addr = _patient;
        hospital = _hospital; //Record the hospital's address

        startTime = block.timestamp; //Start time of the whole process
    }

//---------------------------modifiers---------------------------
    modifier adminOnly(){
        require(msg.sender == admin,"Only accessible by admin staff!");
        _;
    }

    //Only accessible by admin and hospital
    modifier accessedOnly(){
        require(msg.sender == admin || msg.sender == hospital,"Access Denied");
        _;
    }

    //Might be deleted later
    modifier patientOnly(){

        bool isPatient = false;

        //loop through the array named registerList
        //to check that whether the address in a patient
        for (uint8 i=0;i<registerList.length;i++){
            if (msg.sender == registerList[i]){
                isPatient = true;
                break;
            }
        }

        require(isPatient, "Only patient can set his/her info.");
        _;
    }

    modifier validAcc(){
        require(stageAcc == StageAcc.Acc_Activated);
        _;
    }

    modifier validStage(StageServiceRequest reqStage){
        require(stageService==reqStage,"Not in the specified stage.");
        _;
    }

//---------------------------------------------------------------

    function timeNow() public view returns(uint){
        return block.timestamp;
    }

    function check_addr_type(address _address) public view returns(string memory){
        
        //loop through the array named registerList
        //to check that whether the address in a patient
        for (uint8 i=0;i<registerList.length;i++){
            if (_address == registerList[i])
            return "Patient";
        }

        if (_address == admin){
            return "Admin";
        } else if (_address == hospital){
            return "Hospital";
        }
        else{
            return "Unknown";
        }
    }

    function register(address _addressPatient) adminOnly public {
        require(_addressPatient != admin|| _addressPatient != hospital,
                "Can't register a(n) admin/hospital!");
        
        //Call the internal function generate_Client()
        generate_ClientID();

        //assigning default values for name and ID, which can be modified by Client later stage
        patient[_addressPatient].name = userID;
        patient[_addressPatient].id = clientNo;

        //assigns the mapping variables;
        patient[_addressPatient].eligible = true;
        patient[_addressPatient].stage_acc = uint8(stageAcc); //0
        patient[_addressPatient].stage_service = uint8(stageService); //0

        //Append address to the dynamic array
        registerList.push(_addressPatient);

    }

    function check_patient_info(address _addressPatient) accessedOnly public
            returns(string memory,uint8,bool,uint8,uint8){
        
        //Activate the account after activation time of 1 min
        if (block.timestamp > (startTime+ 1 minutes)) {
            stageAcc = StageAcc.Acc_Activated;
            //Update the status of the respective account
            patient[_addressPatient].stage_acc = uint8(stageAcc); //1
        }

        return (patient[_addressPatient].name,
                patient[_addressPatient].id,
                patient[_addressPatient].eligible,
                patient[_addressPatient].stage_acc,
                patient[_addressPatient].stage_service);
                
    }

    //validStage(StageAcc.Acc_Activated)
    function set_name(address _address,string memory _name) validAcc public {
        patient[_address].name = _name;
    }

    function set_id(address _address,uint8 _id) validAcc public {
        patient[_address].id = _id;
    }

    function return_registeredList() adminOnly public view returns (address[] memory) {
        // Create a dynamic array to store the registered voters
        address[] memory registered_patient = new address[](registerList.length);

        // Iterate through the array of registered clients and add each one to the array
        for (uint i = 0; i < registerList.length; i++) {
            address _patient_addr = registerList[i];
            //if (patient[_patient_addr].name != " ") {
                //registered_patient[i] = registerList[i];
                registered_patient[i] = _patient_addr;
            //}
        }
        return registered_patient;
    }

    //requesting for services (e.g. AME/
    function request(uint) validAcc public{

    }

    //Solidity: Is there a way to get the timestamp of a transaction that executed?
    //Ref: https://ethereum.stackexchange.com/questions/9858/solidity-is-there-a-way-to-get-the-timestamp-of-a-transaction-that-executed

    //allows light clients to react on changes efficiently
    event Sent(address from, address to, uint amount);

    function make_payment(address receiver, uint8 amount) public{
        emit Sent(msg.sender,receiver,amount);
    }

    //verifies the signature
    using ECDSA for bytes32; 

    // Recover the signer's address from the hash and signature
    function verifySignature(bytes32 hash, bytes memory signature, address expectedSigner) public pure returns (bool) { 
        // Compare the recovered address with the expected signer 
        address signer = hash.recover(signature); 
        
        return signer == expectedSigner; 

    } 

    //---------------------------All internal function---------------------------
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k-1;
            uint8 temp = uint8(48 + _i % 10);
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }

        return string(bstr);

    }

    //these 2 variables will be updated automatically 
    string private userID = "Client0";
    uint8 private clientNo = 0;

    //interal function that is called by function register()
    //to inctrement the ClientID, from Client0 --> Client1 --> Client2 etc
    function generate_ClientID() internal{
        clientNo ++; //increment by 1
        userID = string(abi.encodePacked("Client", uint2str(clientNo)));
    }

}
