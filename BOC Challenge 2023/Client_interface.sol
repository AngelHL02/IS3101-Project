//Use this contract with the Project_V*.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//interface is used to connect 2 contracts
interface main{
    function acc_request() external;
    function set_self_details(string memory _name, uint _id) external;
    function request_service(uint8 toService) external;
    function make_payment(uint amount) external;

    function getCertifiedList() external view returns (address[] memory);
    function verifySign(bytes32 hash, bytes memory signature) external view returns (bool, address);
}

contract clientView{
    address contractAddr;
    address[] certifiedList;

    constructor(address payable _main){
        contractAddr = _main;
        update_list(); //update the list if needed
    }

    function check_address() public view returns(address){
        return address(msg.sender);
    }

    function acc_request() public{
        main(contractAddr).acc_request();
        //main(contractAddr).acc_request{gas: 200000}();
    }

    function set_self_details(string memory _name, uint _id) public{
        main(contractAddr).set_self_details(_name,_id);
    }

    function request_service(uint8 toService) public{
        main(contractAddr).request_service(toService);
    }

/*
    // in sender contract
    function sendEther(address payable recipient) public payable {
        (bool success, ) = recipient.call{value: 1 ether}("");
        require(success, "Failed to send Ether");
    }

    function withdraw() public {
        address payable recipient = payable(msg.sender);
        recipient.transfer(1 ether);
    }

    receive() external payable {
        // handle the received Ether
    }
*/

    function make_payment(uint amount) payable public{
        // transfer 1 ETH to the main contract
        //address payable mainContract = payable(contractAddr);
        //mainContract.transfer(amount);
        main(contractAddr).make_payment(amount);
    }

    //---------------------------For signature verification---------------------------
    function update_list() public{
        //retrieve the array named registered_patient from the main contract (medical_V2)
        certifiedList = main(contractAddr).getCertifiedList();
    }

    function view_certified_list() public view returns(address[] memory){
        return certifiedList;
    }

    function verifySign(bytes32 hash, bytes memory signature) external view returns (bool, address){
        return main(contractAddr).verifySign(hash,signature);
    }

}

/*
    //---------------------------Testnomial---------------------------
    +ve Case
    Expected Signer:
    0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

    HASH:
    0x4a5c5d454721bbbb25540c3317521e71c373ae36458f960d2ad46ef088110e95
    
    SIGNATURE:
    0x2cc23f074ec0d40421d95b58b67d667120d0a3d4f8feba6c7c5ff88d1ec3a4cb18b3e15bac816bb53a075d045632703600c4ee7ef31ff6fdc237362c8b76fd721c

    -ve Case
    Expected Signer:
    0x17F6AD8Ef982297579C203069C1DbfFE4348c372

    HASH:
    0x4a5c5d454721bbbb25540c3317521e71c373ae36458f960d2ad46ef088110e95

    SIGNATURE:
    0x431b6dd32247f957529d61086b6ed13bde927c732c47addf004175b858ae391c089bd7796b2a8295c9d77a0e230e6c5a94ce9abdedcfe28c10d9a1c5870a30ac1b

*/

