// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CryptexaLabs {
    struct Proof {
        address submitter;
        uint256 timestamp;
        string metadata; // e.g., document hash, IPFS link, description
        bool active;
    }

    uint256 private nextProofId = 1;
    mapping(uint256 => Proof) private proofs;
    mapping(bytes32 => uint256) private hashToProofId;

    event ProofSubmitted(uint256 indexed proofId, address indexed submitter, string metadata, bytes32 docHash);
    event ProofMetadataUpdated(uint256 indexed proofId, string newMetadata);
    event ProofDeactivated(uint256 indexed proofId);

    /// @notice Submit a new proof with document hash and metadata
    function submitProof(bytes32 docHash, string memory metadata) external returns (uint256) {
        require(docHash != bytes32(0), "Invalid document hash");
        require(hashToProofId[docHash] == 0, "Proof already exists");

        uint256 proofId = nextProofId++;
        proofs[proofId] = Proof({
            submitter: msg.sender,
            timestamp: block.timestamp,
            metadata: metadata,
            active: true
        });

        hashToProofId[docHash] = proofId;
        emit ProofSubmitted(proofId, msg.sender, metadata, docHash);
        return proofId;
    }

    /// @notice Update metadata for a proof (only submitter)
    function updateProofMetadata(uint256 proofId, string memory newMetadata) external {
        Proof storage p = proofs[proofId];
        require(p.submitter == msg.sender, "Not the submitter");
        require(p.active, "Proof is inactive");

        p.metadata = newMetadata;
        emit ProofMetadataUpdated(proofId, newMetadata);
    }

    /// @notice Deactivate a proof (only submitter)
    function deactivateProof(uint256 proofId) external {
        Proof storage p = proofs[proofId];
        require(p.submitter == msg.sender, "Not the submitter");
        require(p.active, "Already inactive");

        p.active = false;
        emit ProofDeactivated(proofId);
    }

    /// @notice Retrieve proof details by proof ID
    function getProof(uint256 proofId) external view returns (address submitter, uint256 timestamp, string memory metadata, bool active) {
        Proof memory p = proofs[proofId];
        require(p.timestamp != 0, "Proof not found");
        return (p.submitter, p.timestamp, p.metadata, p.active);
    }

    /// @notice Find proof by document hash
    function findProofByHash(bytes32 docHash) external view returns (uint256) {
        return hashToProofId[docHash];
    }

    /// @notice Total proofs submitted
    function totalProofs() external view returns (uint256) {
        return nextProofId - 1;
    }
}
