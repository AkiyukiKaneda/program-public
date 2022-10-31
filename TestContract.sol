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
        uint256 id;
        uint256 amount;
        uint256 duration;
        uint256 upvotes;
        uint256 downvotes;
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

    mapping(uint256 => ProposalStruct) private proposal;
    mapping(uint256 => mapping(uint256 => VotedStruct)) private vote;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    function getProposal(uint256 _id) external view returns(ProposalStruct memory) {
        return proposal[_id];
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

        uint256 _id = _nextId.current();

        proposal[_id].id = _id;
        proposal[_id].duration = block.timestamp + 30 days;
        proposal[_id].beneficiary = payable(_beneficiary);
        proposal[_id].proposer = _proposer;
        proposal[_id].executor = _executor;
        proposal[_id].title = _title;
        proposal[_id].description = _description;

        _nextId.increment();

        return true;
    }

    function performVote(
        uint256 _tokenId,
        uint256 _id,
        bool _vote
    ) external nonReentrant returns(bool) {
        uint256 _currentVoteId = _totalVote[_id].current();
        require(vote[_id][_currentVoteId].voted != true);
        require(proposal[_id].duration > block.timestamp);
        address owner = ownerOf(_tokenId);
        require(owner == msg.sender);

        vote[_id][_currentVoteId].voter = msg.sender;
        vote[_id][_currentVoteId].timestamp = block.timestamp;
        vote[_id][_currentVoteId].voted = true;

        if(_vote == true){
            proposal[_id].upvotes++;
        } else {
            proposal[_id].downvotes++;
        }

        _totalVote[_id].increment();

        return true;
    }

    function excutor(uint256 _id) external nonReentrant returns(bool) {
        require(proposal[_id].paid != true);
        require(block.timestamp > proposal[_id].duration);
        require(proposal[_id].executor == msg.sender);

        _determination(_id);

        if(proposal[_id].passed) {
            proposal[_id].paid = true;
            payable(proposal[_id].beneficiary).transfer(proposal[_id].amount);
            return true;
        }
        return false;
    }

    function _determination(uint256 _id) internal {
        require(block.timestamp > proposal[_id].duration);

        if(proposal[_id].upvotes > proposal[_id].downvotes) {
            proposal[_id].passed = true;
        } else {
            proposal[_id].passed = false;
        }
    }
}