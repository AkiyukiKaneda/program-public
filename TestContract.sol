// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TestContract is ERC721, Ownable {
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

    Counters.Counter private _nextTokenId;

    mapping(uint256 => mapping(uint256 => ProposalStruct)) private proposal;
    mapping(uint256 => mapping(uint256 => VotedStruct)) private vote;

     function setProposal(
        uint256 _tokenId,
        uint256 _id,
        address _beneficiary,
        address _proposer,
        address _executer,
        string _title,
        string _description
     ) public view returns(bool) {
       require(_nextTokenId == _id);
       require(proposer == msg.sender);

       address owner = ownerOf(_tokenId);

       require(owner == msg.sender);

       proposal[_id][_tokenId].id = _id;
       proposal[_id][_tokenId].duration = block.timestamp + 30 days;
       proposal[_id][_tokenId].beneficiary = _beneficiary;
       proposal[_id][_tokenId].proposer = _proposer;
       proposal[_id][_tokenId].executer = _executer;
       proposal[_id][_tokenId].title = _title;
       proposal[_id][_tokenId].description = _description;

       _nextTokenId.increment();

       return true;
     }

    function vote(uin256 _tokenId, uint256 _id, bool _choosen) public view resturns(bool) {
      require(vote[_id][_tokenId].duration > block.timestamp);
      address owner = ownerOf(_tokenId);
      require(owner == _tokenId);

      vote[_id][_tokenId].voter = msg.sender;
      vote[_id][_tokenId].timestamp = block.timestamp;
      vote[_id][_tokenId].choosen = _choosen;

      return true;
    }
}