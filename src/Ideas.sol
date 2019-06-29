pragma solidity ^0.4.18;

import "../library/StringUtil.sol";
import "./Owner.sol";

contract Ideas is Owner {
    using StringUtil for string;

    struct Idea {
        address author;
        string description;
        IdeaStatus status;
        uint256 timestamp;
        uint256 numberOfSupporters;
        uint256 numberOfAbstained;
        uint256 numberOfVotedAgainst;
        uint256 numberOfParticipants;
        mapping (uint256 => Vote) votes;
        mapping (address => bool) participants;
    }

    struct Vote {
        VoteType voteType;
        string comment;
        address voter;
    }

    event AddIdea(address indexed author, string description, uint256 ideaId);
    event VoteForIdea(address indexed voter, uint256 voteId, uint256 ideaId, VoteType voteType, string comment);
    event SetIdeaStatus(uint256 ideaId, IdeaStatus status);

    enum IdeaStatus {
        DISCUSSION,
        SPAM,
        REJECTED,
        PASSED,
        IMPLEMENTED
    }

    enum VoteType {
        SUPPORT,
        AGAINST,
        ABSTAIN
    }

    uint256 numberOfIdeas = 0;

    mapping (uint256 => Idea) private ideas;

    function addIdea(string _description) onlyUnfrozen public {
        require(!_description.isEmpty());

        uint ideaId = numberOfIdeas;

        ideas[ideaId] = Idea({
            author: msg.sender,
            description: _description,
            status: IdeaStatus.DISCUSSION,
            timestamp: now,
            numberOfSupporters: 0,
            numberOfAbstained: 0,
            numberOfVotedAgainst: 0,
            numberOfParticipants: 0
        });
        numberOfIdeas++;
        AddIdea(msg.sender, _description, ideaId);
    }

    function voteForIdea(VoteType _voteType, uint256 _ideaId, string _comment) onlyUnfrozen private {
        require(isExistIdea(_ideaId));
        Idea storage idea = ideas[_ideaId];
   
        require(!idea.participants[msg.sender]);
        require(idea.status == IdeaStatus.DISCUSSION);

        if (_voteType == VoteType.SUPPORT) {
            idea.numberOfSupporters++;
        } else if (_voteType == VoteType.AGAINST) {
            idea.numberOfVotedAgainst++;
        } else if (_voteType == VoteType.ABSTAIN) {
            idea.numberOfAbstained++;
        } else {
            revert();
        }

        idea.participants[msg.sender] = true;

        uint256 voteId = idea.numberOfParticipants;

        idea.votes[voteId] = Vote({
            voteType: _voteType,
            comment: _comment,
            voter: msg.sender
        });
        idea.numberOfParticipants++;
        VoteForIdea(msg.sender, voteId, _ideaId, _voteType, _comment);
    }

    function supportIdea(uint256 _ideaId, string _comment) public {
        voteForIdea(VoteType.SUPPORT, _ideaId, _comment);
    }

    function againstIdea(uint256 _ideaId, string _comment) public {
        voteForIdea(VoteType.AGAINST, _ideaId, _comment);
    }

    function abstainIdea(uint256 _ideaId, string _comment) public {
        voteForIdea(VoteType.ABSTAIN, _ideaId, _comment);
    }

    function setIdeaStatus(uint256 _ideaId, IdeaStatus _status) onlyOwner public {
        ideas[_ideaId].status = _status;
        SetIdeaStatus(_ideaId, _status);
    }

    function isExistIdea(uint256 _ideaId) view private returns(bool) {
        return ((_ideaId < numberOfIdeas) && (_ideaId >= 0));
    }

    function getIdea(uint256 _ideaId) view public returns(bool exist, uint256 ideaId, address author, string description, IdeaStatus ideaStatus, uint256 timestamp, uint256 numberOfSupporters, uint256 numberOfAbstained, uint256 numberOfVotedAgainst, uint256 numberOfParticipants) {
        if (!isExistIdea(_ideaId)) {
            (exist, ideaId) = (false, _ideaId);
            return;
        }
        Idea storage idea = ideas[_ideaId];
        return (true, _ideaId, idea.author, idea.description, idea.status, idea.timestamp, idea.numberOfSupporters, idea.numberOfAbstained, idea.numberOfVotedAgainst, idea.numberOfParticipants);
    }

    function getVote(uint256 _ideaId, uint256 _voteId) view public returns(bool exist, uint256 ideaId, uint256 idOfVote, address voter, VoteType voteType, string comment) {
        if (isExistIdea(_ideaId)) {
            Idea storage idea = ideas[_ideaId];
            Vote storage vote = idea.votes[_voteId];
            if ((_voteId < idea.numberOfParticipants) && (_voteId >= 0)) {
                return (true, _ideaId, _voteId, vote.voter, vote.voteType, vote.comment);
            }
        }
        (exist, ideaId, idOfVote) = (false, _ideaId, _voteId);
        return;
    }
}