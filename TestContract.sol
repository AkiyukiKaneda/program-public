// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TestContract is ERC721, Ownable {
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
   bool choosen;
  }

  Counters.Counter private _nextId;

  mapping(uint256 => mapping(uint256 =>ProposalStruct)) private proposal;
  mapping(uint256 => mapping(uint256 => VotedStruct)) private vote;

  constructor(
      string memory _name,
      string memory _symbol
  ) ERC721(_name, _symbol) {}

   function setProposal(
     uint256 _tokenId,
     uint256 _id,
     address _beneficiary,
     address _proposer,
     address _executor,
     string memory _title,
     string memory _description
  ) public returns(bool) {
    require(_nextId.current() == _id);
    require(_proposer == msg.sender);

    address owner = ownerOf(_tokenId);

    require(owner == msg.sender);

    proposal[_id][_tokenId].id = _id;
    proposal[_id][_tokenId].duration = block.timestamp + 30 days;
    proposal[_id][_tokenId].beneficiary = payable(_beneficiary);
    proposal[_id][_tokenId].proposer = _proposer;
    proposal[_id][_tokenId].executor = _executor;
    proposal[_id][_tokenId].title = _title;
    proposal[_id][_tokenId].description = _description;

    _nextId.increment();

    return true;
  }

  function performVote(
    uint256 _tokenId,
    uint256 _id,
    bool _choosen
  ) public returns(bool) {
    uint256 _duration = proposal[_id][_tokenId].duration;
    require( _duration > block.timestamp);
    address owner = ownerOf(_tokenId);
    require(owner == msg.sender);

    vote[_id][_tokenId].voter = msg.sender;
    vote[_id][_tokenId].timestamp = block.timestamp;
    vote[_id][_tokenId].choosen = _choosen;

    return true;
  }
}
