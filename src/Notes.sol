pragma solidity ^0.4.0;

import "./Ideas.sol";

contract Notes is Ideas {
    using StringUtil for string;

    enum NoteVisibility {
        PUBLIC,
        UNLISTED
    }

    struct Note {
        uint256 refId;
        address author;
        string content;
        uint256 timestamp;
        NoteVisibility visibility;
    }

    struct NoteRef {
        uint256 noteId;
        address author;
    }

    mapping(address => uint256) private numberOfNotes;
    mapping(address => mapping(uint256 => Note)) private addressNotes;
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

        addressNotes[msg.sender][numberOfSenderNotes] = Note({
            refId: (_visibility == NoteVisibility.PUBLIC) ?  numberOfPublicNotes : 0,
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
        }

        numberOfNotes[msg.sender]++;
    }

    function getNoteByAddress(address _author, uint256 _noteId) view public returns(bool exist, uint256 noteId, NoteVisibility visibility, uint256 refId, string content, address author, uint256 timestamp) {
        if (!isExistNoteByAuthor(_author, _noteId)) {
            (exist, noteId) = (false, _noteId);
            return;
        }
        Note storage note = addressNotes[_author][_noteId];
        return (true, _noteId, note.visibility, note.refId, note.content, note.author, note.timestamp);
    }

    function getNote(uint256 _noteId) view public returns(bool exist, uint256 noteId, NoteVisibility visibility, uint256 refId, string content, address author, uint256 timestamp) {
        if(!isExistNoteRef(_noteId)) {
            (exist, noteId) = (false, _noteId);
            return;
        }
        NoteRef storage noteRef = notes[_noteId];
        return getNoteByAddress(noteRef.author, noteRef.noteId);
    }

    function numberOfPublicNotes() public {
        return numberOfPublicNotes;
    }

    function numberOfNotesByAddress(address _author) public {
        return numberOfNotes[_author];
    }

    function isExistNoteByAuthor(address _author, uint256 _noteId) view private returns(bool) {
        return ((_noteId < numberOfNotes[_author]) && (_noteId >= 0));
    }

    function isExistNoteRef(uint256 _noteId) view private returns(bool) {
        return ((_noteId < numberOfPublicNotes) && (_noteId >= 0));
    }
}
