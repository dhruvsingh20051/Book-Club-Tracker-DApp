// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title GasLess Trade
 * @dev A smart contract enabling gasless trading through meta-transactions and EIP-712 signatures
 */
contract GasLessTrade {
    
    // State variables
    address public owner;
    uint256 public tradeCount;
    uint256 public feePercentage; // Fee in basis points (100 = 1%)
    
    // Structs
    struct Trade {
        address seller;
        address buyer;
        uint256 amount;
        uint256 timestamp;
        bool completed;
    }
    
    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }
    
    // Mappings
    mapping(uint256 => Trade) public trades;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public nonces;
    mapping(address => bool) public authorizedRelayers;
    
    // Events
    event TradeCreated(uint256 indexed tradeId, address indexed seller, address indexed buyer, uint256 amount);
    event TradeCompleted(uint256 indexed tradeId);
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event RelayerAuthorized(address indexed relayer);
    event RelayerRevoked(address indexed relayer);
    event MetaTransactionExecuted(address indexed user, address indexed relayer, bytes functionSignature);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyAuthorizedRelayer() {
        require(authorizedRelayers[msg.sender], "Only authorized relayers can call this function");
        _;
    }
    
    // Constructor
    constructor(uint256 _feePercentage) {
        owner = msg.sender;
        feePercentage = _feePercentage;
        authorizedRelayers[msg.sender] = true;
    }
    
    /**
     * @dev Function 1: Deposit funds into the contract
     */
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @dev Function 2: Withdraw funds from the contract
     */
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
    
    /**
     * @dev Function 3: Create a new trade
     */
    function createTrade(address buyer, uint256 amount) external returns (uint256) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(buyer != address(0), "Invalid buyer address");
        require(buyer != msg.sender, "Cannot trade with yourself");
        
        tradeCount++;
        trades[tradeCount] = Trade({
            seller: msg.sender,
            buyer: buyer,
            amount: amount,
            timestamp: block.timestamp,
            completed: false
        });
        
        emit TradeCreated(tradeCount, msg.sender, buyer, amount);
        return tradeCount;
    }
    
    /**
     * @dev Function 4: Complete a trade
     */
    function completeTrade(uint256 tradeId) external {
        Trade storage trade = trades[tradeId];
        require(!trade.completed, "Trade already completed");
        require(msg.sender == trade.buyer, "Only buyer can complete trade");
        require(balances[trade.seller] >= trade.amount, "Seller has insufficient balance");
        
        uint256 fee = (trade.amount * feePercentage) / 10000;
        uint256 amountAfterFee = trade.amount - fee;
        
        balances[trade.seller] -= trade.amount;
        balances[trade.buyer] += amountAfterFee;
        balances[owner] += fee;
        
        trade.completed = true;
        emit TradeCompleted(tradeId);
    }
    
    /**
     * @dev Function 5: Execute meta-transaction (gasless transaction)
     */
    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) external onlyAuthorizedRelayer returns (bytes memory) {
        MetaTransaction memory metaTx = MetaTransaction({
            nonce: nonces[userAddress],
            from: userAddress,
            functionSignature: functionSignature
        });
        
        require(verify(userAddress, metaTx, sigR, sigS, sigV), "Signature verification failed");
        
        nonces[userAddress]++;
        
        (bool success, bytes memory returnData) = address(this).call(
            abi.encodePacked(functionSignature, userAddress)
        );
        require(success, "Function execution failed");
        
        emit MetaTransactionExecuted(userAddress, msg.sender, functionSignature);
        return returnData;
    }
    
    /**
     * @dev Function 6: Verify meta-transaction signature
     */
    function verify(
        address userAddress,
        MetaTransaction memory metaTx,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) internal pure returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(metaTx.nonce, metaTx.from, metaTx.functionSignature));
        address signer = ecrecover(toEthSignedMessageHash(hash), sigV, sigR, sigS);
        return signer == userAddress;
    }
    
    /**
     * @dev Function 7: Authorize a relayer
     */
    function authorizeRelayer(address relayer) external onlyOwner {
        require(relayer != address(0), "Invalid relayer address");
        authorizedRelayers[relayer] = true;
        emit RelayerAuthorized(relayer);
    }
    
    /**
     * @dev Function 8: Revoke relayer authorization
     */
    function revokeRelayer(address relayer) external onlyOwner {
        authorizedRelayers[relayer] = false;
        emit RelayerRevoked(relayer);
    }
    
    /**
     * @dev Function 9: Update fee percentage
     */
    function updateFeePercentage(uint256 newFeePercentage) external onlyOwner {
        require(newFeePercentage <= 1000, "Fee cannot exceed 10%");
        feePercentage = newFeePercentage;
    }
    
    /**
     * @dev Function 10: Get trade details
     */
    function getTradeDetails(uint256 tradeId) external view returns (
        address seller,
        address buyer,
        uint256 amount,
        uint256 timestamp,
        bool completed
    ) {
        Trade memory trade = trades[tradeId];
        return (trade.seller, trade.buyer, trade.amount, trade.timestamp, trade.completed);
    }
    
    /**
     * @dev Helper function to convert hash to Ethereum signed message hash
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    
    /**
     * @dev Get user balance
     */
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
    
    /**
     * @dev Get user nonce
     */
    function getNonce(address user) external view returns (uint256) {
        return nonces[user];
    }
}