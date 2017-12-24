pragma solidity ^0.4.18;
import "./StringUtil.sol";
import "./Owner.sol";

contract Ideas is StringUtil, Owner {
    struct Idea {
        address author;
        string description;
        uint status;
        uint256 timestamp;
        uint256 numberOfSupporters;
        uint256 numberOfAbstained;
        uint256 numberOfVotedAgainst;
        uint256 numberOfParticipants;
        mapping (uint256 => Vote) votes;
        mapping (address => bool) participants;
    }

    struct Vote {
        uint typeId;
        string comment;
        address voter;
    }

    event AddIdea(address indexed author, string description, uint256 ideaId);
    event VoteForIdea(address indexed voter, uint256 voteId, uint256 ideaId, uint typeId, string comment);
    event SetIdeaStatus(uint256 ideaId, uint status);

    uint constant DISCUSSION = 1;
    uint constant SPAM = 2;
    uint constant REJECTED = 3;
    uint constant PASSED = 4;
    uint constant IMPLEMENTED = 5;
    
    uint constant SUPPORT = 1;
    uint constant AGAINST = 2;
    uint constant ABSTAIN = 3;

    uint256 numberOfIdeas = 0;

    mapping (uint256 => Idea) private ideas;

    function addIdea(string description) onlyUnfrozen public {
        require(!isEmptyString(description));

        uint ideaId = numberOfIdeas;

        ideas[ideaId] = Idea({
            author: msg.sender,
            description: description,
            status: DISCUSSION,
            timestamp: now,
            numberOfSupporters: 0,
            numberOfAbstained: 0,
            numberOfVotedAgainst: 0,
            numberOfParticipants: 0
        });
        numberOfIdeas++;
        AddIdea(msg.sender, description, ideaId);
    }

    function voteForIdea(uint typeId, uint256 ideaId, string comment) onlyUnfrozen private {
        require(isExistIdea(ideaId));
        Idea storage idea = ideas[ideaId];
   
        require(!idea.participants[msg.sender]);
        require(idea.status == DISCUSSION);

        if (typeId == SUPPORT) {
            idea.numberOfSupporters++;
        } else if (typeId == AGAINST) {
            idea.numberOfVotedAgainst++;
        } else if (typeId == ABSTAIN) {
            idea.numberOfAbstained++;
        } else {
            revert();
        }

        idea.participants[msg.sender] = true;

        uint256 voteId = idea.numberOfParticipants;

        idea.votes[voteId] = Vote({
            typeId: typeId,
            comment: comment,
            voter: msg.sender
        });
        idea.numberOfParticipants++;
        VoteForIdea(msg.sender, voteId, ideaId, typeId, comment);
    }

    function supportIdea(uint256 id, string comment) public {
        voteForIdea(SUPPORT, id, comment);
    }

    function againstIdea(uint256 id, string comment) public {
        voteForIdea(AGAINST, id, comment);
    }

    function abstainIdea(uint256 id, string comment) public {
        voteForIdea(ABSTAIN, id, comment);
    }

    function setIdeaStatus(uint256 ideaId, uint status) onlyOwner public {
        ideas[ideaId].status = status;
        SetIdeaStatus(ideaId, status);
    }

    function isExistIdea(uint256 ideaId) view private returns(bool) {
        return ((ideaId < numberOfIdeas) && (ideaId >= 0));
    }

    function getIdea(uint256 ideaId) view public returns(bool exist, uint256 idOfIdea, address author, string description, uint idOfStatus, uint256 timestamp, uint256 numberOfSupporters, uint256 numberOfAbstained, uint256 numberOfVotedAgainst, uint256 numberOfParticipants) {
        if (!isExistIdea(ideaId)) {
            (exist, idOfIdea) = (false, ideaId);
            return;
        }
        Idea storage idea = ideas[ideaId];
        return (true, ideaId, idea.author, idea.description, idea.status, idea.timestamp, idea.numberOfSupporters, idea.numberOfAbstained, idea.numberOfVotedAgainst, idea.numberOfParticipants);
    }

    function getVote(uint256 ideaId, uint256 voteId) view public returns(bool exist, uint256 idOfIdea, uint256 idOfVote, address voter, uint idOfType, string comment) {
        if (isExistIdea(ideaId)) {
            Idea storage idea = ideas[ideaId];
            Vote storage vote = idea.votes[voteId];
            if ((voteId < idea.numberOfParticipants) && (voteId >= 0)) {
                return (true, ideaId, voteId, vote.voter, vote.typeId, vote.comment);
            }
        }
        (exist, idOfIdea, idOfVote) = (false, ideaId, voteId);
        return;
    }
}