// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Datumark
/// @notice Wallet-owned public file manifests. File bytes remain on IPFS.
contract Datumark {
    uint256 public constant MAX_PAGE_SIZE = 100;
    uint256 public constant MAX_URI_BYTES = 220;
    uint256 public constant MAX_NAME_BYTES = 96;
    uint256 public constant MAX_MIME_BYTES = 64;

    struct Cabinet {
        string label;
        address owner;
        uint64 createdAt;
        uint64 updatedAt;
        uint256 liveRecords;
        bool exists;
    }

    struct Record {
        string uri;
        string name;
        string mimeType;
        uint64 size;
        uint64 addedAt;
        bool exists;
    }

    mapping(address => Cabinet) private _cabinets;
    mapping(address => mapping(uint256 => Record)) private _records;
    mapping(address => uint256[]) private _recordIds;
    mapping(address => uint256) public nextRecordId;

    uint256 public cabinetCount;
    uint256 public recordCount;

    event CabinetCreated(address indexed owner, string label, uint64 createdAt);
    event CabinetRenamed(address indexed owner, string label);
    event RecordAdded(address indexed owner, uint256 indexed recordId, string uri, string name, string mimeType, uint64 size);
    event RecordRemoved(address indexed owner, uint256 indexed recordId);

    function createCabinet(string calldata label) external {
        require(!_cabinets[msg.sender].exists, "cabinet exists");
        _validateLabel(label);
        uint64 now64 = uint64(block.timestamp);
        _cabinets[msg.sender] = Cabinet({label: label, owner: msg.sender, createdAt: now64, updatedAt: now64, liveRecords: 0, exists: true});
        nextRecordId[msg.sender] = 1;
        cabinetCount += 1;
        emit CabinetCreated(msg.sender, label, now64);
    }

    function renameCabinet(string calldata newLabel) external {
        Cabinet storage cabinet = _requireCabinet(msg.sender);
        _validateLabel(newLabel);
        cabinet.label = newLabel;
        cabinet.updatedAt = uint64(block.timestamp);
        emit CabinetRenamed(msg.sender, newLabel);
    }

    function addRecord(string calldata uri, string calldata name, string calldata mimeType, uint64 size) external returns (uint256 recordId) {
        Cabinet storage cabinet = _requireCabinet(msg.sender);
        require(bytes(uri).length >= 8 && bytes(uri).length <= MAX_URI_BYTES, "bad uri");
        require(bytes(name).length > 0 && bytes(name).length <= MAX_NAME_BYTES, "bad name");
        require(bytes(mimeType).length <= MAX_MIME_BYTES, "bad mime");

        recordId = nextRecordId[msg.sender]++;
        uint64 now64 = uint64(block.timestamp);
        _records[msg.sender][recordId] = Record({uri: uri, name: name, mimeType: mimeType, size: size, addedAt: now64, exists: true});
        _recordIds[msg.sender].push(recordId);
        cabinet.liveRecords += 1;
        cabinet.updatedAt = now64;
        recordCount += 1;
        emit RecordAdded(msg.sender, recordId, uri, name, mimeType, size);
    }

    function removeRecord(uint256 recordId) external {
        Cabinet storage cabinet = _requireCabinet(msg.sender);
        Record storage item = _records[msg.sender][recordId];
        require(item.exists, "record missing");
        item.exists = false;
        cabinet.liveRecords -= 1;
        cabinet.updatedAt = uint64(block.timestamp);
        recordCount -= 1;
        emit RecordRemoved(msg.sender, recordId);
    }

    function getCabinet(address owner) external view returns (Cabinet memory) {
        return _cabinets[owner];
    }

    function getRecord(address owner, uint256 recordId) external view returns (Record memory) {
        return _records[owner][recordId];
    }

    function listRecords(address owner, uint256 offset, uint256 limit) external view returns (Record[] memory entries, uint256[] memory ids, uint256 total) {
        require(limit > 0 && limit <= MAX_PAGE_SIZE, "bad limit");
        uint256[] storage allIds = _recordIds[owner];
        total = allIds.length;
        if (offset >= total) return (new Record[](0), new uint256[](0), total);
        uint256 end = offset + limit;
        if (end > total) end = total;
        uint256 length = end - offset;
        entries = new Record[](length);
        ids = new uint256[](length);
        for (uint256 i; i < length; ++i) {
            uint256 id = allIds[offset + i];
            entries[i] = _records[owner][id];
            ids[i] = id;
        }
    }

    function _requireCabinet(address owner) private view returns (Cabinet storage cabinet) {
        cabinet = _cabinets[owner];
        require(cabinet.exists, "no cabinet");
    }

    function _validateLabel(string calldata label) private pure {
        require(bytes(label).length > 0 && bytes(label).length <= 64, "bad label");
    }
}