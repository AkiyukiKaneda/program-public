// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TestContract is ERC721, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    using Counters for Counters.Counter;

    struct ProposalStruct {
        uint256 proposalId;
        uint256 amount;
        uint256 duration;
        uint256 nbYes;
        uint256 nbNo;
        address payable beneficiary;
        address proposer;
        address executor;
        string title;
        string description;
        bool passed;
        bool paid;
    }

    struct VotedStruct {
       address voter;
       uint256 timestamp;
       bool voted;
    }

    Counters.Counter private _nextId;
    mapping(uint256 => Counters.Counter) private _totalVote;

    mapping(uint256 => ProposalStruct) private proposals;
    mapping(uint256 => mapping(uint256 => VotedStruct)) private votes;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    function getProposal(uint256 _proposalId) external view returns(ProposalStruct memory) {
        return proposals[_proposalId];
    }

    function performProposal(
        uint256 _tokenId,
        address _beneficiary,
        address _proposer,
        address _executor,
        string memory _title,
        string memory _description
    ) external returns(bool) {
        require(_proposer == msg.sender);

        address owner = ownerOf(_tokenId);

        require(owner == msg.sender);

        uint256 _proposalId = _nextId.current();

        proposals[_proposalId].proposalId = _proposalId;
        proposals[_proposalId].duration = block.timestamp + 30 days;
        proposals[_proposalId].beneficiary = payable(_beneficiary);
        proposals[_proposalId].proposer = _proposer;
        proposals[_proposalId].executor = _executor;
        proposals[_proposalId].title = _title;
        proposals[_proposalId].description = _description;

        _nextId.increment();

        return true;
    }

    function performVote(
        uint256 _tokenId,
        uint256 _proposalId,
        bool _vote
    ) external nonReentrant returns(bool) {
        uint256 _currentVoteId = _totalVote[_proposalId].current();
        require(votes[_proposalId][_currentVoteId].voted != true);
        require(proposals[_proposalId].duration > block.timestamp);
        address owner = ownerOf(_tokenId);
        require(owner == msg.sender);

        votes[_proposalId][_currentVoteId].voter = msg.sender;
        votes[_proposalId][_currentVoteId].timestamp = block.timestamp;
        votes[_proposalId][_currentVoteId].voted = true;

        if(_vote == true){
            proposals[_proposalId].nbYes++;
        } else {
            proposals[_proposalId].nbNo++;
        }

        _totalVote[_proposalId].increment();

        return true;
    }

    function excutor(uint256 _proposalId) external nonReentrant returns(bool) {
        require(proposals[_proposalId].paid != true);
        require(block.timestamp > proposals[_proposalId].duration);
        require(proposals[_proposalId].executor == msg.sender);

        _determination(_proposalId);

        if(proposals[_proposalId].passed) {
            proposals[_proposalId].paid = true;
            payable(proposals[_proposalId].beneficiary).transfer(proposals[_proposalId].amount);
            return true;
        }
        return false;
    }

    function _determination(uint256 _proposalId) internal {
        require(block.timestamp > proposals[_proposalId].duration);

        if(proposals[_proposalId].nbYes > proposals[_proposalId].nbNo) {
            proposals[_proposalId].passed = true;
        } else {
            proposals[_proposalId].passed = false;
        }
    }
}