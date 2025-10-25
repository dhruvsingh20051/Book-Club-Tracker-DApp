# Book Club Tracker DApp

A decentralized application (DApp) for tracking book club activities, including book reviews and reading logs.

## Features

- Add and track books with title and author
- Write book reviews with ratings (1-5 stars)
- Log reading progress with page counts and notes
- View average ratings and total reviews for each book
- Track personal reading progress
- Connect with Web3 wallet (MetaMask)

## Tech Stack

- Solidity (Smart Contract)
- Web3.js
- HTML/JavaScript
- Tailwind CSS
- MetaMask (Web3 Provider)

## Prerequisites

- Node.js and npm installed
- MetaMask browser extension
- A Web3-compatible browser
- Access to an Ethereum network (local or testnet)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/book-club-tracker
cd book-club-tracker
```

2. Install dependencies:
```bash
npm install
```

3. Deploy the smart contract:
   - Compile the Solidity contract using your preferred development environment (Remix, Truffle, or Hardhat)
   - Deploy to your chosen network (local testnet or mainnet)
   - Save the deployed contract address

4. Configure the frontend:
   - Open `index.html`
   - Replace `YOUR_CONTRACT_ADDRESS` with your deployed contract address
   - Replace the `contractABI` array with your contract's ABI

## Usage

1. Start a local server:
```bash
npx http-server
```

2. Open your browser and navigate to `http://localhost:8080`

3. Connect your MetaMask wallet:
   - Click "Connect Wallet" button
   - Approve the connection in MetaMask
   - Ensure you're on the correct network

4. Using the DApp:
   - Add Books:
     - Fill in the book title and author
     - Click "Add Book"
     - Confirm the transaction in MetaMask
   
   - Write Reviews:
     - Select a book from the dropdown
     - Choose a rating (1-5 stars)
     - Write your review
     - Click "Submit Review"
   
   - Log Reading Progress:
     - Select a book
     - Enter pages read
     - Add optional notes
     - Click "Add Log Entry"

## Smart Contract Functions

### Main Functions

```solidity
function addBook(string memory title, string memory author) public returns (bytes32)
function addReview(bytes32 bookId, uint256 rating, string memory comment) public
function addReadingLog(bytes32 bookId, uint256 pagesRead, string memory notes) public
function getBookAverageRating(bytes32 bookId) public view returns (uint256)
function getReadingLogs(bytes32 bookId, address reader) public view returns (ReadingLog[] memory)
function getAllBooks() public view returns (bytes32[] memory)
function getBookDetails(bytes32 bookId) public view returns (string memory title, string memory author, uint256 totalReviews)
```

## Data Structures

```solidity
struct Book {
    string title;
    string author;
    uint256 totalReviews;
    uint256 totalRating;
    bool exists;
}

struct Review {
    address reviewer;
    uint256 rating;
    string comment;
    uint256 timestamp;
}

struct ReadingLog {
    uint256 pagesRead;
    string notes;
    uint256 timestamp;
}
```

## Security Considerations

- The smart contract includes basic access controls
- Users can only submit one review per book
- All data is stored on-chain, ensuring transparency
- Input validation is implemented for ratings (1-5 stars)

## Development

To modify the DApp:

1. Smart Contract:
   - Modify `BookClubTracker.sol`
   - Recompile and deploy
   - Update ABI and address in frontend

2. Frontend:
   - Modify `index.html`
   - Update Web3 integration as needed
   - Adjust styling using Tailwind classes

## Testing

1. Smart Contract Testing:
   - Test all functions with various inputs
   - Verify access controls
   - Check error handling
   - Validate data storage and retrieval

2. Frontend Testing:
   - Test wallet connection
   - Verify all form submissions
   - Check error messages
   - Test responsiveness

## Troubleshooting

Common issues and solutions:

1. MetaMask not connecting:
   - Ensure MetaMask is installed and unlocked
   - Check if you're on the correct network

2. Transactions failing:
   - Check if you have enough ETH for gas
   - Verify you're connected to the correct network
   - Ensure input data is valid

3. Books not displaying:
   - Check console for errors
   - Verify contract address and ABI
   - Confirm Web3 connection

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License