// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

    //import"solidity-datetime/DateTimeContract.sol";
    import"solidity-datetime/DateTime.sol";

    contract DocumentRegistry {

    struct Document {
        uint256 timestamp;    // Timestamp of when the document was added
        bytes32 documentHash;  // Cryptographic hash of the document's content
        bytes signature;
    }

    mapping(bytes32 => Document) public documents;  // Mapping to store documents by their hash

    // Function to add a document to the registry
    function addDocument(bytes32 _documentHash, bytes memory _signature) public {
        require(documents[_documentHash].timestamp == 0, 
        "Document already exists");  // Check if document already exists

        // Store document with its hash and current timestamp
        documents[_documentHash] = Document(block.timestamp,_documentHash,_signature);  
    }

    // Function to get the timestamp of a document
    function getDocumentTimestamp(bytes32 _documentHash) public view returns (uint256) {
        require(documents[_documentHash].timestamp != 0, 
        "Document does not exist");  // Check if document exists

        // Return the timestamp of the document
        return documents[_documentHash].timestamp;  
    }

    //Using the DateTime library for date conversion
    using DateTime for uint256;

    function timestampToDateTime(uint256 timestamp) public pure
        returns (uint256 year, uint256 month, uint256 day, 
                uint256 hour, uint256 minute, uint256 second)
    {
        (year, month, day, hour, minute, second) = DateTime.timestampToDateTime(timestamp);
    }

}