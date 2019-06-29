pragma solidity ^0.4.0;

contract Notes {
    enum NoteType {
        PUBLIC,
        PRIVATE
    }

    struct Note {
        NoteType type;
        address author;
        string content;
        uint256 timestamp;
    }
}
