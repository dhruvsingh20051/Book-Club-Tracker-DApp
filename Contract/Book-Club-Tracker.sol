// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Book Club Tracker DApp
 * @notice A decentralized platform for managing book clubs — tracking members, reading lists, and shared reviews on-chain.
 * @dev This DApp promotes transparency and engagement by storing reading activity and feedback immutably on the blockchain.
 */
contract Project {
    address public admin;
    uint256 public bookCount;
    uint256 public memberCount;

    struct Member {
        uint256 id;
        address wallet;
        string name;
        uint256 booksRead;
        bool registered;
    }

    struct Book {
        uint256 id;
        string title;
        string author;
        string review;
        address submittedBy;
        uint256 timestamp;
    }

    mapping(address => Member) public members;
    mapping(uint256 => Book) public books;
    mapping(address => uint256[]) public memberBooks;

    event MemberRegistered(uint256 indexed id, address indexed wallet, string name);
    event BookAdded(uint256 indexed id, string title, string author, address indexed member);
    event BookReviewed(uint256 indexed id, address indexed reviewer, string review);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender].registered, "You must be a registered member");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Register a new member in the book club.
     * @param _name The display name of the new member.
     */
    function registerMember(string memory _name) external {
        require(!members[msg.sender].registered, "Already registered");
        require(bytes(_name).length > 0, "Name cannot be empty");

        memberCount++;
        members[msg.sender] = Member({
            id: memberCount,
            wallet: msg.sender,
            name: _name,
            booksRead: 0,
            registered: true
        });

        emit MemberRegistered(memberCount, msg.sender, _name);
    }

    /**
     * @notice Add a new book to the club's reading list.
     * @param _title The title of the book.
     * @param _author The author of the book.
     */
    function addBook(string memory _title, string memory _author) external onlyMember {
        require(bytes(_title).length > 0, "Book title required");
        require(bytes(_author).length > 0, "Book author required");

        bookCount++;
        books[bookCount] = Book({
            id: bookCount,
            title: _title,
            author: _author,
            review: "",
            submittedBy: msg.sender,
            timestamp: block.timestamp
        });

        memberBooks[msg.sender].push(bookCount);

        emit BookAdded(bookCount, _title, _author, msg.sender);
    }

    /**
     * @notice Add or update a review for a book.
     * @param _bookId ID of the book.
     * @param _review Review text.
     */
    function addReview(uint256 _bookId, string memory _review) external onlyMember {
        require(_bookId > 0 && _bookId <= bookCount, "Invalid book ID");
        require(bytes(_review).length > 0, "Review cannot be empty");

        books[_bookId].review = _review;
        members[msg.sender].booksRead++;

        emit BookReviewed(_bookId, msg.sender, _review);
    }

    /**
     * @notice Retrieve details of a book.
     * @param _bookId ID of the book.
     * @return The full book structure.
     */
    function getBook(uint256 _bookId) external view returns (Book memory) {
        require(_bookId > 0 && _bookId <= bookCount, "Invalid book ID");
        return books[_bookId];
    }

    /**
     * @notice Retrieve all book IDs submitted by a specific member.
     * @param _member Address of the member.
     * @return Array of book IDs submitted by the member.
     */
    function getMemberBooks(address _member) external view returns (uint256[] memory) {
        return memberBooks[_member];
    }

    /**
     * @notice Change admin ownership to a new address.
     * @param _newAdmin Address of the new admin.
     */
    function transferOwnership(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
}

