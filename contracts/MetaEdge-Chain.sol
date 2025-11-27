// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MetaEdgeChain {
    struct Record {
        address owner;
        uint256 timestamp;
        string metadata; // Could be hash, description, or IPFS link
        bool active;
    }

    uint256 private nextRecordId = 1;
    mapping(uint256 => Record) private records;
    mapping(bytes32 => uint256) private hashToRecordId;

    event RecordAdded(uint256 indexed recordId, address indexed owner, string metadata, bytes32 docHash);
    event RecordUpdated(uint256 indexed recordId, string newMetadata);
    event RecordDeactivated(uint256 indexed recordId);

    /// @notice Add a new record with hash & metadata
    function addRecord(bytes32 docHash, string memory metadata) external returns (uint256) {
        require(docHash != bytes32(0), "Invalid hash");
        require(hashToRecordId[docHash] == 0, "Record already exists");

        uint256 recordId = nextRecordId++;
        records[recordId] = Record({
            owner: msg.sender,
            timestamp: block.timestamp,
            metadata: metadata,
            active: true
        });

        hashToRecordId[docHash] = recordId;

        emit RecordAdded(recordId, msg.sender, metadata, docHash);
        return recordId;
    }

    /// @notice Update metadata for a record (only owner)
    function updateRecord(uint256 recordId, string memory newMetadata) external {
        Record storage r = records[recordId];
        require(r.owner == msg.sender, "Not owner");
        require(r.active, "Record inactive");

        r.metadata = newMetadata;
        emit RecordUpdated(recordId, newMetadata);
    }

    /// @notice Deactivate a record (only owner)
    function deactivateRecord(uint256 recordId) external {
        Record storage r = records[recordId];
        require(r.owner == msg.sender, "Not owner");
        require(r.active, "Already inactive");

        r.active = false;
        emit RecordDeactivated(recordId);
    }

    /// @notice View record by ID
    function getRecord(uint256 recordId) external view returns (address owner, uint256 timestamp, string memory metadata, bool active) {
        Record memory r = records[recordId];
        require(r.timestamp != 0, "Record not found");
        return (r.owner, r.timestamp, r.metadata, r.active);
    }

    /// @notice Find record by hash
    function findRecordByHash(bytes32 docHash) external view returns (uint256) {
        return hashToRecordId[docHash];
    }

    /// @notice Total records added
    function totalRecords() external view returns (uint256) {
        return nextRecordId - 1;
    }
}
