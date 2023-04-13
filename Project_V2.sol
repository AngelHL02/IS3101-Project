// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import required packages
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol"; 

contract medical_V2{

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
        uint id;
        bool eligible; //default is false
        uint8 service_requested;
        uint service_fee;
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

    constructor(address payable _hospital,uint8 _numService){
        admin = msg.sender;
        hospital = _hospital; //Record the hospital's address

        startTime = block.timestamp; //Start time of the whole process

        //initialize the serviceCount array with _numService no. of Service structs
        //each with a service_Count of 0
        for (uint8 i=0; i<_numService;i++){
            serviceCount.push(Service(0));
        }

        //Add the addresses to the certifiedList
        certifiedList.push(msg.sender);

        //prevent adding of address to the CertifiedList array
        //in the case that the admin = hospital
        if (msg.sender != _hospital) certifiedList.push(_hospital);

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

    modifier validAcc(){
        require(patient[msg.sender].stage_acc==1,"Account not yet activated.");
        _;
    }

    modifier inState(StageServiceRequest reqStage){
        require(patient[msg.sender].stage_service==uint8(reqStage),
                "Not in the specified stage.");
        _;
    }

    //----------------------------------------------------------------

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
    function acc_request() public {
        require(msg.sender != admin && msg.sender != hospital, "Can't register a(n) admin/hospital!");

        //check whether the inputted address is in the registered_patient array
        isExistingPatient(msg.sender);
        require(!isPatient, "Account is already registered!");
        
        //Call the internal function generate_Client()
        generate_ClientID();

        //assigning default values for name and ID, which can be modified by Client later stage
        patient[msg.sender].name = userID;
        patient[msg.sender].id = clientNo;

        //assigns the mapping variables;
        patient[msg.sender].eligible = false;
        patient[msg.sender].service_requested = 0;
        patient[msg.sender].stage_acc = uint8(StageAcc.Init); //0
        patient[msg.sender].stage_service = uint8(StageServiceRequest.Init); //0

        //Append address to the dynamic array
        clientList.push(msg.sender);

    }

    //Active the account for a particular patient after 
    function acc_activate(address _addressPatient) adminOnly public returns(string memory){

        //check whether the inputted address is in the registered_patient array
        isExistingPatient(_addressPatient);
        require(isPatient, "Patient not found.");

        //reset the bool
        isPatient = false;

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

    function check_client_info(address _addressPatient) accessedOnly view public
            returns(string memory, uint, bool, uint8, uint8, uint8){

        //if the address is in the clientList
        for (uint8 i=0; i<clientList.length; i++){
            if (_addressPatient == clientList[i]){
                return (patient[_addressPatient].name,
                        patient[_addressPatient].id,
                        patient[_addressPatient].eligible,
                        patient[_addressPatient].service_requested,
                        patient[_addressPatient].stage_acc,
                        patient[_addressPatient].stage_service);
            }
        }

        // If the function reaches this point, the patient was not found in the clientList array.
        revert("Patient not found.");
    }
    
    function set_name(string memory _name) validAcc public {
        patient[msg.sender].name = _name;
    }

    function set_id(uint _id) validAcc public {
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
    //requesting for services (e.g. A&E/Radiologu/Pharmacy/Cardiology)
    function request_service(uint8 toService) validAcc public{

        //check whether the inputted address is in the registered_patient array
        isExistingPatient(msg.sender);
        require(isPatient, "Only registered patient can request for a service");

        //reset the bool
        isPatient = false;

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

    function cancel_service() validAcc inState(StageServiceRequest.Requested) public{

        patient[msg.sender].stage_service = uint8(StageServiceRequest.Cancel); //2

        //transform patient[_addressPatient].service_requested back to 0-based
        uint8 toService = patient[msg.sender].service_requested - 1;
        //remove his/her queue in the array
        serviceCount[toService]._Count -= 1;

        //---Delete later (Replaced with calling function)
        //restore the request service limit
        //patient[msg.sender].eligible = true; 
        //reset the value of requested service
        //patient[msg.sender].service_requested = 0;

        reset_service_status(msg.sender);

    }

    //uint public service_fee;

    function confirm_request(address _addressPatient, uint _amount) accessedOnly public{

        patient[_addressPatient].stage_service = uint8(StageServiceRequest.Confirmed); //3
        patient[_addressPatient].service_fee = _amount;

        //transform patient[_addressPatient].service_requested back to 0-based
        uint8 toService = patient[_addressPatient].service_requested - 1 ; 
        //remove his/her queue in the array
        serviceCount[toService]._Count -= 1;

        //service_fee = _amount;

        //---Delete later (Replaced with calling function)
        //restore the request service limit
        //patient[_addressPatient].eligible = true; 
        //reset the value of requested service
        //patient[_addressPatient].service_requested = 0;

        reset_service_status(_addressPatient);

    }

    function my_service_fee() validAcc inState(StageServiceRequest.Confirmed) public view returns(uint){
        return patient[msg.sender].service_fee;
    }

    function make_payment(uint8 amount) validAcc inState(StageServiceRequest.Confirmed) 
            payable public{
        require(msg.value == patient[msg.sender].service_fee,"Incorrect Amount.");
        patient[msg.sender].stage_service = uint8(StageServiceRequest.Done); //4

        //---Delete later (Replaced with calling function)
        //restore the request service limit
        //patient[msg.sender].eligible = true; 
        //reset the value of requested service
        //patient[msg.sender].service_requested = 0;

        reset_service_status(msg.sender);

        hospital.transfer(amount);


        patient[msg.sender].service_fee = 0;

        emit paymentSettled(msg.sender,hospital,amount);

    }

    function done(address _addressPatient) accessedOnly public{

        patient[_addressPatient].stage_service = uint8(StageServiceRequest.Done); //4

        //transform patient[_addressPatient].service_requested back to 0-based
        uint8 toService = patient[_addressPatient].service_requested - 1 ; 
        //remove his/her queue in the array
        serviceCount[toService]._Count -= 1;

        //---Delete later (Replaced with calling function)
        //restore the request service limit
        //patient[_addressPatient].eligible = true; 
        //reset the value of requested service
        //patient[_addressPatient].service_requested = 0;

        reset_service_status(_addressPatient);

    }

    function reject_request(address _addressPatient) accessedOnly public{
        patient[_addressPatient].stage_service = uint8(StageServiceRequest.Rejected); //5

        //transform patient[_addressPatient].service_requested back to 0-based
        uint8 toService = patient[_addressPatient].service_requested - 1 ; 
        //remove his/her queue in the array
        serviceCount[toService]._Count -= 1;

        //---Delete later (Replaced with calling function)
        //restore the request service limit
        //patient[_addressPatient].eligible = true; 
        //reset the value of requested service
        //patient[_addressPatient].service_requested = 0;

        reset_service_status(_addressPatient);

    }

    //return the array containing the cumulative service count
    function check_queue() accessedOnly public view returns(Service[] memory){
        return serviceCount;
    }

    //allows light clients to react on changes efficiently
    event paymentSettled(address from, address to, uint amount);

    //---------------------------For signature verification---------------------------
    address[] certifiedList; //Use to store adresses of certified parties

    bool isMatch; //default = false

    function generate_message(address _addressPatient,string memory message)
            accessedOnly public view returns (string memory) {

        //if the address is in the clientList
        for (uint8 i=0; i<clientList.length; i++) {
            if (_addressPatient == clientList[i]) {
                return string(abi.encodePacked(patient[_addressPatient].name, 
                '-', uint2str(patient[_addressPatient].id),'-',message));
            }
        }

        // If the function reaches this point, the patient was not found in the clientList array.
        revert("Patient not found.");
    }

    event certifiedListUpdated();

    function add_Certified(address _address) adminOnly public {
        //check whether the inputted address exists in the certifiedList already
        for (uint8 i=0;i<certifiedList.length;i++){
            if(_address==certifiedList[i]){
                isMatch = true;
            }
        }
        
        //!isMatch := isMatch = false
        require(!isMatch,"Address already certified.");

        certifiedList.push(_address);
        isMatch = false; //reset isMatch

        emit certifiedListUpdated();
    }

    function getCertifiedList() public view returns (address[] memory) {
        return certifiedList;
    }

    //verifies the signature with the ECDSA.sol library
    using ECDSA for bytes32;

    // Recover the signer's address from the hash and signature
    // then compare it one by one in the address in the certifiedList
    // to check its authenticity
    function verifySign(bytes32 hash, bytes memory signature) 
            public view returns (bool, address) {
        // Recover the signer's address from the hash and signature
        address signer = hash.recover(signature);

        // Check if the recovered signer is in the expected signers list
        for (uint i = 0; i < certifiedList.length; i++) {
            if (signer == certifiedList[i]) {
                return (true, signer);
            }
        }

        // Signature is invalid if the recovered signer is not in the expected signers list
        // address(0) will return an address of: 0x0000000000000000000000000000000000000000
        return (false, address(0));
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

    //this function resets the status related to service request
    function reset_service_status(address _addressPatient) internal{

        //restore the request service limit
        patient[_addressPatient].eligible = true; 
        //reset the value of requested service
        patient[_addressPatient].service_requested = 0;

    }

    //check whether the _addressPatient has applied for an account already
    bool isPatient;

    //check whether it is a registered patient address
    function isExistingPatient(address _address) internal{
        //loop through the array named clientList
        //to check that whether the address in a patient
        for (uint8 i=0;i<clientList.length;i++){
            if (_address == clientList[i]){
                isPatient = true;
                break;
            }
        }
    }

}
