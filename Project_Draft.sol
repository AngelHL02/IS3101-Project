// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract medical{

/*  TO BE CONTINUED in later time
    Goal: 
    (i) Having multiple users
    (ii) Different user can have different stages for stage_acc & stage_service
*/

//--------------------------- settings---------------------------
    //Class: patient
    struct Patient{
        string name;
        uint8 hkid;
        //uint acc_activateTime; 
        bool eligible; //default is false
        uint8 stage_acc; //from enum StageAcc
        uint8 stage_service; //from enum Stage
    }

/*  Count the no. of patients that request for a particular service
    struct patient_list{
        uint listCount;
    }

*/

    address public admin;
    address payable public hospital;

    //mapping (address => uint) public balances; //Keep check of user's balance
    mapping (address => Patient) patient; 

    uint public startTime;
    address[] registerList;
    
    enum StageAcc {Init, Acc_Activated}
    enum StageServiceRequest {Init,Requested,Pending,Confirmed,Reject}

//  --> Change to store in patient mapping
    //initialize the initial status of stage
    //global stage initialization
    StageAcc stageAcc = StageAcc.Init; //0
    StageServiceRequest stageService = StageServiceRequest.Init; //0

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

/*
    modifier patientOnly(){
        require(msg.sender == patient_addr, "Only patient can set his/her info.");
        _;
    }
*/

/*
    modifier validStage(StageServiceRequest reqStage){
        require(stage_service==reqStage,"Not in the specified stage.");
        _;
    }

*/

    //Only accessible by admin and hospital
    modifier accessedOnly(){
        require(msg.sender == admin || msg.sender == hospital,"Access Denied");
        _;
    }

//---------------------------------------------------------------
    function timeNow() public view returns(uint){
        return block.timestamp;
    }

    function register(address _address) adminOnly public {

        patient[_address].eligible = true;
        patient[_address].stage_acc = uint8(stageAcc);
        patient[_address].stage_service = uint8(stageService);

/*
        if (block.timestamp > (startTime+ 1 minutes)) {
            stageAcc = StageAcc.Acc_Activated;
        }

        if (stageAcc = StageAcc.Acc_Activated) {
            patient[_addressPatient].stage_acc = 0;
        }
*/

    }

    function set_name(address _address,string memory _name) public {
        patient[_address].name = _name;
    }

    //requesting for services (e.g. AME/
    function request(uint) public{

    }

/*
    //Check the current (application) status for request services
    function check_status() public{

    }
*/

    //Ref: https://ethereum.stackexchange.com/questions/9858/solidity-is-there-a-way-to-get-the-timestamp-of-a-transaction-that-executed

    //verifies the signature
    function verify_signature(string memory _name) public returns (bool){

    }

    //allows light clients to react on changes efficiently
    event Sent(address from, address to, uint amount);

    function make_payment(address _receiver, uint _amount) public{

    }

/* References code ---- sending $
    function send (address receiver, uint amount) public {
        if (balances[msg.sender] < amount) return; //stop the process

        //if amount > balance ---> Process
        //update the balance of the sender
        balances[msg.sender] -= amount;

        //update the balance of the receiver 
        balances[receiver] += amount; 

        //Notify the receiver
        emit Sent(msg.sender, receiver, amount);
        
        //not a must that the receiver
        //only if the receiver "listen" to the event
    }
*/

}
