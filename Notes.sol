pragma solidity ^0.4.0;

contract Notes {
    enum NoteVisibility {
        PUBLIC,
        UNLISTED
    }

    struct Note {
        NoteVisibility visibility;
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

    function addNote(NoteVisibility visibility, string content) private {
        Note memory note = Note({
            visibility: visibility,
            author: msg.sender,
            content: content,
            timestamp: now
        });
        addressNotes[msg.sender].push(note);

        NoteRef memory noteRef = NoteRef({
            noteId: notes.length,
            author: msg.sender
        });
        notes.push(noteRef);
    }
}
