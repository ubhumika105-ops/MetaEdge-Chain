// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MetaEdge-Chain
 * @dev A decentralized platform for digital asset creation, transfer, and ownership tracking.
 */
contract MetaEdgeChain {
    struct Asset {
        uint256 id;
        string name;
        address creator;
        address currentOwner;
    }

    mapping(uint256 => Asset) public assets;
    uint256 public assetCount;

    event AssetCreated(uint256 indexed id, string name, address indexed creator);
    event OwnershipTransferred(uint256 indexed id, address indexed from, address indexed to);

    /**
     * @dev Create a new digital asset.
     * @param _name The name of the asset.
     */
    function createAsset(string memory _name) public {
        assetCount++;
        assets[assetCount] = Asset(assetCount, _name, msg.sender, msg.sender);
        emit AssetCreated(assetCount, _name, msg.sender);
    }

    /**
     * @dev Transfer ownership of an asset to another user.
     * @param _assetId The ID of the asset to transfer.
     * @param _newOwner The address of the new owner.
     */
    function transferOwnership(uint256 _assetId, address _newOwner) public {
        Asset storage asset = assets[_assetId];
        require(msg.sender == asset.currentOwner, "Only owner can transfer");
        require(_newOwner != address(0), "Invalid address");

        address previousOwner = asset.currentOwner;
        asset.currentOwner = _newOwner;
        emit OwnershipTransferred(_assetId, previousOwner, _newOwner);
    }

    /**
     * @dev Retrieve details of a specific asset.
     * @param _assetId The ID of the asset.
     */
    function getAsset(uint256 _assetId)
        public
        view
        returns (uint256, string memory, address, address)
    {
        Asset memory asset = assets[_assetId];
        return (asset.id, asset.name, asset.creator, asset.currentOwner);
    }
}
