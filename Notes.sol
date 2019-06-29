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
}
