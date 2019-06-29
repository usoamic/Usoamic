pragma solidity ^0.4.0;

contract Notes {
    enum NoteVisibility {
        PUBLIC,
        UNLISTED
    }

    struct Note {
        NoteVisibility visibility;
        int256 refId;
        address author;
        string content;
        uint256 timestamp;
    }

    struct NoteRef {
        uint256 noteId;
        address author;
    }

    mapping(address => Note[]) private addressNotes;
    NoteRef[] notes;

    function addPublicNote(string _content) public {
        addNote(NoteVisibility.PUBLIC, _content);
    }

    function addUnlistedNote(string _content) public {
        addNote(NoteVisibility.UNLISTED, _content);
    }

    function addNote(NoteVisibility _visibility, string _content) private {
        Note memory note = Note({
            refId: _visibility == NoteVisibility.PUBLIC ? notes.length : -1,
            visibility: _visibility,
            author: msg.sender,
            content: _content,
            timestamp: now
        });
        addressNotes[msg.sender].push(note);

        if(_visibility == NoteVisibility.PUBLIC) {
            NoteRef memory noteRef = NoteRef({
                noteId: addressNotes[msg.sender].length,
                author: msg.sender
            });
            notes.push(noteRef);
        }
    }

    function getNoteByAddress(address _author, uint256 _noteId) view public returns(bool exist, uint256 noteId, NoteVisibility visibility, int256 refId, string content, address author, uint256 timestamp) {
        if (!isExistNoteByAuthor(_author, _noteId)) {
            (exist, idOfNote) = (false, _noteId);
            return;
        }
        Note storage note = addressNotes[_author][_noteId];
        return (true, _noteId, note.visibility, note.refId, note.content, note.author, note.timestamp);
    }

    function getNote(uint256 _noteId) view public returns(bool exist, uint256 noteId, NoteVisibility visibility, int256 refId, string content, address author, uint256 timestamp) {
        if(!isExistNoteRef(_noteId)) {
            (exist, idOfNote) = (false, _noteId);
            return;
        }
        NoteRef storage noteRef = notes[_noteId];
        return getNoteByAddress(noteRef.author, noteRef.noteId);
    }

    function isExistNoteByAuthor(address _author, uint256 _noteId) view private returns(bool) {
        return ((_noteId < addressNotes[_author].length) && (_noteId >= 0));
    }

    function isExistNoteRef(uint256 _noteId) view private returns(bool) {
        return ((_noteId < notes.length) && (_noteId >= 0));
    }
}
