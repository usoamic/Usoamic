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
}
