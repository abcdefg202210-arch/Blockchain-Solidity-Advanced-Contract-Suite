// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAOVotingAdvanced {
    IERC20 public governanceToken;
    uint256 public votingDuration = 3 days;

    struct Proposal {
        address proposer;
        string description;
        uint256 voteFor;
        uint256 voteAgainst;
        uint256 endTime;
        bool executed;
        bool canceled;
    }

    Proposal[] public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    mapping(uint256 => mapping(address => bool)) public voteChoice;

    event ProposalCreated(uint256 id, string description);
    event Voted(uint256 id, address voter, bool support, uint256 weight);
    event ProposalExecuted(uint256 id);

    constructor(address _token) {
        governanceToken = IERC20(_token);
    }

    function createProposal(string calldata description) external returns (uint256) {
        proposals.push(Proposal({
            proposer: msg.sender,
            description: description,
            voteFor: 0,
            voteAgainst: 0,
            endTime: block.timestamp + votingDuration,
            executed: false,
            canceled: false
        }));
        emit ProposalCreated(proposals.length - 1, description);
        return proposals.length - 1;
    }

    function vote(uint256 proposalId, bool support) external {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp < p.endTime, "Voting ended");
        require(!hasVoted[msg.sender][proposalId], "Already voted");
        uint256 weight = governanceToken.balanceOf(msg.sender);
        require(weight > 0, "No voting power");
        hasVoted[msg.sender][proposalId] = true;
        support ? p.voteFor += weight : p.voteAgainst += weight;
        emit Voted(proposalId, msg.sender, support, weight);
    }

    function executeProposal(uint256 proposalId) external {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp > p.endTime, "Voting not ended");
        require(!p.executed, "Already executed");
        require(p.voteFor > p.voteAgainst, "Rejected");
        p.executed = true;
        emit ProposalExecuted(proposalId);
    }
}
