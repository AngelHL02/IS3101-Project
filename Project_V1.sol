// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import required packages
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol"; 

contract medical{

/*
    For testing:
    hospital: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

    Others: 
    0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    0x617F2E2fD72FD9D5503197092aC168c91465E7f2
*/

//--------------------------- Settings---------------------------

    //Class: patient
    struct Patient{
        string name;
        uint8 id;
        //uint acc_activateTime; 
        bool eligible; //default is false
        uint8 service_requested;
        uint8 stage_acc; //from enum StageAcc
        uint8 stage_service; //from enum Stage
    }

    struct Service{
        uint8 _Count;
    }

    Service[] serviceCount; //Keep track of the no. of service requested
    address[] clientList; //Used to store the address of registered clients

    address public admin;
    address payable public hospital;

    mapping (address => Patient) patient; 

    uint public startTime;
    
    //enum used to keep track of stages
    enum StageAcc {Init, Acc_Activated}
    enum StageServiceRequest {Init,Requested,Cancel,Confirmed,Done,Rejected}

/*  Delete later
    //initialize the initial status of stages
    //StageAcc stageAcc = StageAcc.Init; //0
    //StageServiceRequest stageService = StageServiceRequest.Init; //0
*/

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

/*  May be deleted later
    modifier patientOnly(){

        bool isPatient = false;

        //loop through the array named clientList
        //to check that whether the address in a patient
        for (uint8 i=0;i<clientList.length;i++){
            if (msg.sender == clientList[i]){
                isPatient = true;
                break;
            }
        }

        require(isPatient, "Only patient can set his/her info.");
        _;
    }
*/
    modifier validAcc(){
        //require(stageAcc == StageAcc.Acc_Activated);
        require(patient[msg.sender].stage_acc==1,"Account not yet activated.");
        _;
    }

    modifier validStage(StageServiceRequest reqStage){
        require(patient[msg.sender].stage_service==uint8(reqStage),
                "Not in the specified stage.");
        _;
    }

//---------------------------------------------------------------

    function timeNow() public view returns(uint){
        return block.timestamp;
    }

    function check_addr_type(address _address) public view returns(string memory){
        
        //loop through the array named clientList
        //to check that whether the address in a patient
        for (uint8 i=0;i<clientList.length;i++){
            if (_address == clientList[i])
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

    //---------------------------Client Management---------------------------
    function register_client(address _addressPatient) adminOnly public {
        require(_addressPatient != admin|| _addressPatient != hospital,
                "Can't register a(n) admin/hospital!");
        
        //Call the internal function generate_Client()
        generate_ClientID();

        //assigning default values for name and ID, which can be modified by Client later stage
        patient[_addressPatient].name = userID;
        patient[_addressPatient].id = clientNo;

        //assigns the mapping variables;
        patient[_addressPatient].eligible = false;
        patient[_addressPatient].service_requested = 0;
        patient[_addressPatient].stage_acc = uint8(StageAcc.Init); //0
        patient[_addressPatient].stage_service = uint8(StageServiceRequest.Init); //0

        //Append address to the dynamic array
        clientList.push(_addressPatient);

    }

    //Active the account for a particular patient after 
    function acc_activate(address _addressPatient) accessedOnly public returns(string memory){

        //Activate the account after activation time of 1 min
        if (block.timestamp > (startTime+ 1 minutes)) {
            //stageAcc = StageAcc.Acc_Activated;

            //Update the status of the respective account
            patient[_addressPatient].stage_acc = uint8(StageAcc.Acc_Activated); //1
            //Enable the requesting of service function
            patient[_addressPatient].eligible = true; 
            return "Account activated.";
        } else {
            return "Account not yet activated.";
        }
    }

    function check_patient_info(address _addressPatient) accessedOnly view public
            returns(string memory,uint8,bool,uint8,uint8,uint8){

        return (patient[_addressPatient].name,
                patient[_addressPatient].id,
                patient[_addressPatient].eligible,
                patient[_addressPatient].service_requested,
                patient[_addressPatient].stage_acc,
                patient[_addressPatient].stage_service);
                
    }
    
    function set_name(string memory _name) public {
        patient[msg.sender].name = _name;
    }

    function set_id(uint8 _id) public {
        patient[msg.sender].id = _id;
    }

    function client_List() adminOnly public view returns (address[] memory) {
        // Create a dynamic array to store the registered voters
        address[] memory registered_patient = new address[](clientList.length);

        // Iterate through the array of registered clients and add each one to the array
        for (uint i = 0; i < clientList.length; i++) {
            address _patient_addr = clientList[i];
                registered_patient[i] = _patient_addr;
        }
        return registered_patient;
    }

    //---------------------------For service request---------------------------
    function set_num_service(uint _numService) accessedOnly public {
        //initialize the serviceCount array with _numService no. of Service structs
        //each with a service_Count of 0
        for (uint8 i=0; i<_numService;i++){
            serviceCount.push(Service(0));
        }
    }

    //requesting for services (e.g. A&E/Radiologu/Pharmacy/Cardiology)
    function request_service(uint8 toService) validAcc public{
        require(toService<=serviceCount.length,"Service unavailable.");
        require(patient[msg.sender].eligible=true,"You can only register for 1 service at a time.");
        
        //record which service that the client has requested
        patient[msg.sender].service_requested = toService;

        toService --; // toService is 1-based, while Solidity is 0-based
        serviceCount[toService]._Count += 1;

        patient[msg.sender].eligible = false; 
        patient[msg.sender].stage_service = uint8(StageServiceRequest.Requested); //1
        //A patient can only request a single service at a time
    }

    function cancel_request() validAcc public{

        patient[msg.sender].stage_service = uint8(StageServiceRequest.Cancel); //2

        //transform patient[_addressPatient].service_requested back to 0-based
        uint8 toService = patient[msg.sender].service_requested - 1;
        //remove his/her queue in the array
        serviceCount[toService]._Count -= 1;

        //restore the request service limit
        patient[msg.sender].eligible = true; 
        //reset the value of requested service
        patient[msg.sender].service_requested = 0;

    }

    function confirm_request(address _addressPatient) accessedOnly public{

        patient[_addressPatient].stage_service = uint8(StageServiceRequest.Confirmed); //3

        //transform patient[_addressPatient].service_requested back to 0-based
        uint8 toService = patient[_addressPatient].service_requested - 1 ; 
        //remove his/her queue in the array
        serviceCount[toService]._Count -= 1;

        //restore the request service limit
        patient[_addressPatient].eligible = true; 
        //reset the value of requested service
        patient[_addressPatient].service_requested = 0;

    }

    function make_payment(address payable receiver, uint8 amount) validAcc payable public{
        patient[msg.sender].stage_service = uint8(StageServiceRequest.Done); //4

        //restore the request service limit
        patient[msg.sender].eligible = true; 
        //reset the value of requested service
        patient[msg.sender].service_requested = 0;

        receiver.transfer(amount);
        emit Sent(msg.sender,receiver,amount);

    }

    function reject_request(address _addressPatient) accessedOnly public{
        patient[_addressPatient].stage_service = uint8(StageServiceRequest.Rejected); //5

        //transform patient[_addressPatient].service_requested back to 0-based
        uint8 toService = patient[_addressPatient].service_requested - 1 ; 
        //remove his/her queue in the array
        serviceCount[toService]._Count -= 1;

        //restore the request service limit
        patient[_addressPatient].eligible = true; 
        //reset the value of requested service
        patient[_addressPatient].service_requested = 0;

    }

    //return the array containing the cumulative service count
    function check_queue() accessedOnly public view returns(Service[] memory){
        return serviceCount;
    }

    //allows light clients to react on changes efficiently
    event Sent(address from, address to, uint amount);

    //---------------------------For signature verification---------------------------
    address[] certifiedList; //Use to store 

    //verifies the signature with the ECDSA.sol library
    using ECDSA for bytes32;

    // Recover the signer's address from the hash and signature
    function verifySignature(bytes32 hash, bytes memory signature, address expectedSigner) 
        public pure returns (bool,address) { 
        // Compare the recovered address with the expected signer 
        address signer = hash.recover(signature); 
        
        return (signer == expectedSigner,signer); 

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
        //update new userID
        userID = string(abi.encodePacked("Client", uint2str(clientNo)));
    }

}
