pragma solidity ^0.4.19;

import "../library/StringUtil.sol";
import "./Owner.sol";

contract Ideas is Owner {
    using StringUtil for string;

    event AddIdea(address indexed author, string description, uint256 ideaId);
    event VoteForIdea(address indexed voter, uint256 voteId, uint256 ideaRefId, VoteType voteType, string comment);
    event SetIdeaStatus(uint256 ideaRefId, IdeaStatus status);

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

    struct IdeaRef {
        uint256 ideaId;
        address author;
    }

    struct VoteRef {
        uint256 voteId;
        address voter;
    }

    struct Idea {
        uint256 ideaRefId;
        address author;
        string description;
        IdeaStatus status;
        uint256 timestamp;
        uint256 numberOfSupporters;
        uint256 numberOfAbstained;
        uint256 numberOfVotedAgainst;
        uint256 numberOfParticipants;
        mapping(uint256 => VoteRef) votes;
        mapping(address => bool) participants;
    }

    struct Vote {
        uint256 ideaRefId;
        uint256 voteRefId;
        VoteType voteType;
        string comment;
        address voter;
    }

    mapping(address => uint256) numberOfVotesByVoter;
    mapping(address => mapping(uint256 => Vote)) voterVotes;
    mapping(uint256 => IdeaRef) private ideas;
    mapping(address => mapping(uint256 => Idea)) private authorIdeas;
    mapping(address => uint256) private numberOfIdeasByAuthor;

    uint256 private numberOfIdeas = 0;

    function addIdea(string _description) onlyUnfrozen public {
        require(!_description.isEmpty());

        uint256 ideaId = numberOfIdeasByAuthor[msg.sender];
        uint256 ideaRefId = numberOfIdeas;

        authorIdeas[msg.sender][ideaId] = Idea({
            author : msg.sender,
            ideaRefId : ideaRefId,
            description : _description,
            status : IdeaStatus.DISCUSSION,
            timestamp : now,
            numberOfSupporters : 0,
            numberOfAbstained : 0,
            numberOfVotedAgainst : 0,
            numberOfParticipants : 0
            });

        ideas[ideaRefId] = IdeaRef({
            ideaId : ideaId,
            author : msg.sender
            });

        AddIdea(msg.sender, _description, ideaId);

        numberOfIdeas++;
        numberOfIdeasByAuthor[msg.sender]++;
    }

    function voteForIdea(VoteType _voteType, uint256 _ideaRefId, string _comment) onlyUnfrozen private {
        require(isExistIdea(_ideaRefId));
        IdeaRef storage ideaRef = ideas[_ideaRefId];
        Idea storage idea = authorIdeas[ideaRef.author][ideaRef.ideaId];

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

        uint256 voteRefId = idea.numberOfParticipants;
        uint256 voteId = numberOfVotesByVoter[msg.sender];

        voterVotes[msg.sender][voteId] = Vote({
            ideaRefId : _ideaRefId,
            voteRefId : voteRefId,
            voteType : _voteType,
            comment : _comment,
            voter : msg.sender
        });

        idea.votes[voteRefId] = VoteRef({
            voteId : voteId,
            voter : msg.sender
        });

        idea.numberOfParticipants++;
        numberOfVotesByVoter[msg.sender]++;

        VoteForIdea(msg.sender, voteId, _ideaRefId, _voteType, _comment);
    }

    function supportIdea(uint256 _ideaRefId, string _comment) public {
        voteForIdea(VoteType.SUPPORT, _ideaRefId, _comment);
    }

    function againstIdea(uint256 _ideaRefId, string _comment) public {
        voteForIdea(VoteType.AGAINST, _ideaRefId, _comment);
    }

    function abstainIdea(uint256 _ideaRefId, string _comment) public {
        voteForIdea(VoteType.ABSTAIN, _ideaRefId, _comment);
    }

    function setIdeaStatus(uint256 _ideaRefId, IdeaStatus _status) onlyOwner public {
        IdeaRef storage ideaRef = ideas[_ideaRefId];
        authorIdeas[ideaRef.author][ideaRef.ideaId].status = _status;
        SetIdeaStatus(_ideaRefId, _status);
    }

    function isExistIdea(uint256 _ideaRefId) view private returns (bool) {
        return ((_ideaRefId < numberOfIdeas) && (_ideaRefId >= 0));
    }

    function isExistIdeaByAuthor(address _author, uint256 _ideaId) view private returns (bool) {
        return ((_ideaId < numberOfIdeasByAuthor[_author]) && (_ideaId >= 0));
    }

    function isExistVoteByVoter(address _voter, uint256 _voteId) view private returns (bool) {
        return ((_voteId < numberOfVotesByVoter[_voter] && (_voteId >= 0)));
    }

    function getIdea(uint256 _ideaRefId) view public returns (bool exist, uint256 ideaId, uint256 ideaRefId, address author, string description, IdeaStatus ideaStatus, uint256 timestamp, uint256 numberOfSupporters, uint256 numberOfAbstained, uint256 numberOfVotedAgainst, uint256 numberOfParticipants) {
        if (!isExistIdea(_ideaRefId)) {
            (exist, ideaId) = (false, _ideaRefId);
            return;
        }
        IdeaRef storage ideaRef = ideas[_ideaRefId];
        return getIdeaByAuthor(ideaRef.author, ideaRef.ideaId);
    }

    function getIdeaByAuthor(address _author, uint256 _ideaId) view public returns (bool exist, uint256 ideaId, uint256 ideaRefId, address author, string description, IdeaStatus ideaStatus, uint256 timestamp, uint256 numberOfSupporters, uint256 numberOfAbstained, uint256 numberOfVotedAgainst, uint256 numberOfParticipants) {
        if (!isExistIdeaByAuthor(_author, _ideaId)) {
            (exist, ideaId) = (false, _ideaId);
            return;
        }
        Idea storage idea = authorIdeas[_author][_ideaId];
        return (true, _ideaId, idea.ideaRefId, idea.author, idea.description, idea.status, idea.timestamp, idea.numberOfSupporters, idea.numberOfAbstained, idea.numberOfVotedAgainst, idea.numberOfParticipants);

    }

    function getVote(uint256 _ideaRefId, uint256 _voteRefId) view public returns (bool exist, uint256 ideaId, uint256 voteId, address voter, VoteType voteType, string comment) {
        if (isExistIdea(_ideaRefId)) {
            IdeaRef storage ideaRef = ideas[_ideaRefId];
            Idea storage idea = authorIdeas[ideaRef.author][ideaRef.ideaId];

            if ((_voteRefId < idea.numberOfParticipants) && (_voteRefId >= 0)) {
                VoteRef storage voteRef = idea.votes[_voteRefId];
                return getVoteByVoter(voteRef.voter, voteRef.voteId);
            }
        }
        (exist, ideaId, voteId) = (false, _ideaRefId, _voteRefId);
        return;
    }

    function getVoteByVoter(address _voter, uint256 _voteId) view public returns (bool exist, uint256 ideaId, uint256 voteId, address voter, VoteType voteType, string comment) {
        if (isExistVoteByVoter(_voter, _voteId)) {
            Vote storage vote = voterVotes[_voter][_voteId];
            return (true, vote.ideaRefId, _voteId, _voter, vote.voteType, vote.comment);
        }
        (exist, voteId) = (false, _voteId);
        return;
    }

    function getNumberOfIdeas() view public returns (uint256) {
        return numberOfIdeas;
    }

    function getNumberOfVotesByVoter(address _voter) view public returns (uint256) {
        return numberOfVotesByVoter[_voter];
    }

    function getNumberOfIdeasByAuthor(address _author) view public returns (uint256) {
        return numberOfIdeasByAuthor[_author];
    }
}