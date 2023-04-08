// SPDX-License-Identifier: MIT

    pragma solidity ^0.8.0;

    contract test_userID{
        string public userID = "User0";
        uint8 public Count = 0;

    function generate_userID() public{
        Count ++;
        //string memory userID2 = string(abi.encodePacked("User", uint2str(Count)));
        userID = string(abi.encodePacked("User", uint2str(Count)));
        //return userID;
    }
    
    function call_gen_ID() public{
        generate_userID();
    }

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

}
    //------------------------------------------------------------------------------------
    pragma solidity ^0.8.0;

    contract str_concat {
        string public str1 = "Hello ";
        string public str2 = "World";

        function concat1() public view returns (string memory){
            return string(abi.encodePacked(str1, str2));
        }

        function concat2(string memory str3,string memory str4) public pure returns(string memory){
            return string(abi.encodePacked(str3, str4));
        }

    }

    //------------------------------------------------------------------------------------
    pragma solidity ^0.8.0;

    contract name_validation {

        function isValidName(string memory name) public pure returns (bool) {
            bytes32 hash = keccak256(bytes(name));
            bytes memory pattern = hex"436c69656e74";
            bytes memory wildcard = hex"2a"; //**

            // Check if the name starts with "Client"
            if (hash[0] == pattern[0] && hash[1] == pattern[1] && 
                hash[2] == pattern[2] && hash[3] == pattern[3]) {
                // Check if the rest of the name matches the wildcard pattern
                for (uint i = 4; i < 32; i++) {
                    if (pattern[i] == wildcard[0]) {
                        continue;
                    }
                    if (hash[i] != pattern[i]) {
                        return false;
                    }
                }
                return true;
            }
            
            // If the name doesn't start with "Client", it's valid
            return true;
        }

    }
    
    //------------------------------------------------------------------------------------
    pragma solidity ^0.8.0;

    contract payment {

    address payable receiver;
    address host;

    constructor (address payable _receiver){
        receiver = _receiver;
        host = msg.sender;
    }

    function make_payment(uint8 amount) payable public{
        receiver.transfer(amount);
    }

    function check_bal() external view returns(uint){
        return msg.sender.balance;
    }

    function receiver_bal() external view returns(uint256){
        return address(receiver).balance;
    }

}


    pragma solidity ^0.8.0;

    contract TestArray {
        address[] certifiedList;

        function addAddress(address _address) public {
            certifiedList.push(_address);
        }

        function getCertifiedList() public view returns (address[] memory) {
            return certifiedList;
        }
}

    //Combined
    pragma solidity ^0.8.0;

    import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

    contract VerifySign_array {
        using ECDSA for bytes32;

        address[] certifiedList;

        function addAddress(address _address) public {
            certifiedList.push(_address);
        }

        function getCertifiedList() public view returns (address[] memory) {
            return certifiedList;
        }

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
            return (false, address(0));
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
