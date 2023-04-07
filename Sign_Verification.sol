

    pragma solidity ^0.8.0; 

    import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol"; 

    contract verifySign { 

    using ECDSA for bytes32; 

    // Recover the signer's address from the hash and signature
    function verifySign1(bytes32 hash, bytes memory signature, address expectedSigner) public pure returns (bool) { 
        // Compare the recovered address with the expected signer 
        address signer = hash.recover(signature); 
        
        return signer == expectedSigner; 

    } 

/*  Base
    // Recover the signer's address from the hash and signature
    function verifySignature(bytes32 hash, bytes memory signature, address expectedSigner) 
        public pure returns (bool,address) { 
        // Compare the recovered address with the expected signer 
        address signer = hash.recover(signature); 
        
        return (signer == expectedSigner,signer); 

    } 

*/

    function verifySign2(bytes32 hash, bytes memory signature) public pure returns (bool, address) {
        // Define the expected signer address
        address expectedSigner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

        // Recover the signer's address from the hash and signature
        address signer = hash.recover(signature);

        // Compare the recovered address with the expected signer
        bool isExpectedSigner = (signer == expectedSigner);

        return (isExpectedSigner, signer);
    }
}

    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.0;

    import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

    contract verifySign3 {
        using ECDSA for bytes32;

    address[] signer_list;

    constructor(){
        signer_list = new address[](2);
        signer_list[0] = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        signer_list[1] = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    }

    function verifySign_3(bytes32 hash, bytes memory signature) 
            public view returns (bool, address) {
        // Recover the signer's address from the hash and signature
        address signer = hash.recover(signature);

        // Check if the recovered signer is in the expected signers list
        for (uint i = 0; i < signer_list.length; i++) {
            if (signer == signer_list[i]) {
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



