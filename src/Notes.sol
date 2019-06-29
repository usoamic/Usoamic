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

    function addPublicNote(string content) public {
        addNote(NoteVisibility.PUBLIC, content);
    }

    function addUnlistedNote(string content) public {
        addNote(NoteVisibility.UNLISTED, content);
    }

    function addNote(NoteVisibility visibility, string content) private {
        Note memory note = Note({
            refId: visibility == NoteVisibility.PUBLIC ? notes.length : -1,
            visibility: visibility,
            author: msg.sender,
            content: content,
            timestamp: now
        });
        addressNotes[msg.sender].push(note);

        if(visibility == NoteVisibility.PUBLIC) {
            NoteRef memory noteRef = NoteRef({
                noteId: addressNotes[msg.sender].length,
                author: msg.sender
            });
            notes.push(noteRef);
        }
    }

    function getNoteByAddress(address author, uint256 noteId) view public returns(bool exist, uint256 idOfNote, NoteVisibility visibility, int256 refId, string content, address author, uint256 timestamp) {
        if (!isExistNoteByAuthor(author, noteId)) {
            (exist, idOfNote) = (false, noteId);
            return;
        }
        Note storage note = addressNotes[author][noteId];
        return (true, noteId, note.visibility, note.refId, note.content, note.author, note.timestamp);
    }

    function getNote(uint256 noteId) view public returns(bool exist, uint256 idOfNote, NoteVisibility visibility, int256 refId, string content, address author, uint256 timestamp) {
        if(!isExistNoteRef(noteId)) {
            (exist, idOfNote) = (false, noteId);
            return;
        }
        NoteRef storage noteRef = notes[noteId];
        return getNoteByAddress(noteRef.author, noteRef.noteId);
    }

    function isExistNoteByAuthor(address author, uint256 noteId) view private returns(bool) {
        return ((noteId < addressNotes[author].length) && (noteId >= 0));
    }

    function isExistNoteRef(uint256 noteId) view private returns(bool) {
        return ((noteId < notes.length) && (noteId >= 0));
    }
}
