// SPDX-License-Identifier: 
pragma solidity ^0.8.0;
contract BookClubTracker {
    struct Book {
        string title;
        string author;
        uint256 totalReviews;
        uint256 totalRating;
        bool exists;
    }

    struct Review {
        address reviewer;
        uint256 rating; // 1-5 stars
        string comment;
        uint256 timestamp;
    }

    struct ReadingLog {
        uint256 pagesRead;
        string notes;
        uint256 timestamp;
    }

    mapping(bytes32 => Book) public books;
    mapping(bytes32 => mapping(address => Review)) public bookReviews;
    mapping(bytes32 => mapping(address => ReadingLog[])) public readingLogs;
    bytes32[] public bookList;

    event BookAdded(bytes32 indexed bookId, string title, string author);
    event ReviewAdded(bytes32 indexed bookId, address indexed reviewer, uint256 rating);
    event LogAdded(bytes32 indexed bookId, address indexed reader, uint256 pagesRead);

    modifier bookExists(bytes32 bookId) {
        require(books[bookId].exists, "Book does not exist");
        _;
    }

    function addBook(string memory title, string memory author) public returns (bytes32) {
        bytes32 bookId = keccak256(abi.encodePacked(title, author));
        require(!books[bookId].exists, "Book already exists");

        books[bookId] = Book({
            title: title,
            author: author,
            totalReviews: 0,
            totalRating: 0,
            exists: true
        });

        bookList.push(bookId);
        emit BookAdded(bookId, title, author);
        return bookId;
    }

    function addReview(bytes32 bookId, uint256 rating, string memory comment) 
        public 
        bookExists(bookId) 
    {
        require(rating >= 1 && rating <= 5, "Rating must be between 1 and 5");
        require(bookReviews[bookId][msg.sender].timestamp == 0, "Already reviewed");

        bookReviews[bookId][msg.sender] = Review({
            reviewer: msg.sender,
            rating: rating,
            comment: comment,
            timestamp: block.timestamp
        });

        books[bookId].totalReviews++;
        books[bookId].totalRating += rating;

        emit ReviewAdded(bookId, msg.sender, rating);
    }

    function addReadingLog(bytes32 bookId, uint256 pagesRead, string memory notes) 
        public 
        bookExists(bookId) 
    {
        readingLogs[bookId][msg.sender].push(ReadingLog({
            pagesRead: pagesRead,
            notes: notes,
            timestamp: block.timestamp
        }));

        emit LogAdded(bookId, msg.sender, pagesRead);
    }

    function getBookAverageRating(bytes32 bookId) 
        public 
        view 
        bookExists(bookId) 
        returns (uint256) 
    {
        if (books[bookId].totalReviews == 0) return 0;
        return books[bookId].totalRating / books[bookId].totalReviews;
    }

    function getReadingLogs(bytes32 bookId, address reader) 
        public 
        view 
        returns (ReadingLog[] memory) 
    {
        return readingLogs[bookId][reader];
    }

    function getAllBooks() public view returns (bytes32[] memory) {
        return bookList;
    }

    function getBookDetails(bytes32 bookId) 
        public 
        view 
        bookExists(bookId) 
        returns (string memory title, string memory author, uint256 totalReviews) 
    {
        Book memory book = books[bookId];
        return (book.title, book.author, book.totalReviews);
    }
}















