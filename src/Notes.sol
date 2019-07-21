pragma solidity ^0.4.19;

import "./Ideas.sol";

contract Notes is Ideas {
    using StringUtil for string;

    enum NoteVisibility {
        PUBLIC,
        UNLISTED
    }

    struct Note {
        uint256 noteRefId;
        address author;
        string content;
        uint256 timestamp;
        NoteVisibility visibility;
    }

    struct NoteRef {
        uint256 noteId;
        address author;
    }

    event AddNote(address indexed author, uint256 noteRefId, string content, uint256 timestamp);

    mapping(address => uint256) private numberOfNotes;
    mapping(address => mapping(uint256 => Note)) private authorNotes;
    mapping(uint256 => NoteRef) private notes;

    uint256 private numberOfPublicNotes = 0;

    function addPublicNote(string _content) onlyUnfrozen public {
        addNote(NoteVisibility.PUBLIC, _content);
    }

    function addUnlistedNote(string _content) onlyUnfrozen public {
        addNote(NoteVisibility.UNLISTED, _content);
    }

    function addNote(NoteVisibility _visibility, string _content) onlyUnfrozen private {
        require(!_content.isEmpty());

        uint256 numberOfSenderNotes = numberOfNotes[msg.sender];

        authorNotes[msg.sender][numberOfSenderNotes] = Note({
            noteRefId: (_visibility == NoteVisibility.PUBLIC) ?  numberOfPublicNotes : 0,
            visibility: _visibility,
            author: msg.sender,
            content: _content,
            timestamp: now
        });

        if(_visibility == NoteVisibility.PUBLIC) {
            notes[numberOfPublicNotes] = NoteRef({
                noteId: numberOfSenderNotes,
                author: msg.sender
            });
            numberOfPublicNotes++;
            AddNote(msg.sender, numberOfPublicNotes, _content, now);
        }

        numberOfNotes[msg.sender]++;
    }

    function getNoteByAuthor(address _author, uint256 _noteId) view public returns(bool exist, uint256 noteId, NoteVisibility visibility, uint256 noteRefId, string content, address author, uint256 timestamp) {
        if (!isExistNoteByAuthor(_author, _noteId)) {
            (exist, noteId) = (false, _noteId);
            return;
        }
        Note storage note = authorNotes[_author][_noteId];
        return (true, _noteId, note.visibility, note.noteRefId, note.content, note.author, note.timestamp);
    }

    function getNote(uint256 _noteRefId) view public returns(bool exist, uint256 noteId, NoteVisibility visibility, uint256 noteRefId, string content, address author, uint256 timestamp) {
        if(!isExistNoteRef(_noteRefId)) {
            (exist, noteId) = (false, _noteRefId);
            return;
        }
        NoteRef storage noteRef = notes[_noteRefId];
        return getNoteByAuthor(noteRef.author, noteRef.noteId);
    }

    function getNumberOfPublicNotes() view public returns (uint256) {
        return numberOfPublicNotes;
    }

    function getNumberOfNotesByAuthor(address _author) view public returns (uint256) {
        return numberOfNotes[_author];
    }

    function isExistNoteByAuthor(address _author, uint256 _noteId) view private returns(bool) {
        return ((_noteId < numberOfNotes[_author]) && (_noteId >= 0));
    }

    function isExistNoteRef(uint256 _noteRefId) view private returns(bool) {
        return ((_noteRefId < numberOfPublicNotes) && (_noteRefId >= 0));
    }
}
