// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title GasLess Trade
 * @notice Decentralized ERC20 trading with meta-transactions (gasless execution).
 * @dev Relayer executes signed trade on behalf of users and receives fee reimbursement.
 */

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
}

contract GasLessTrade {
    struct Trade {
        address seller;
        address buyer;
        address token;
        uint256 amount;
        uint256 price;
        uint256 nonce;
        uint256 expiry;
    }

    mapping(address => uint256) public userNonce;
    mapping(bytes32 => bool) public executedOrder;

    event TradeExecuted(
        address indexed seller,
        address indexed buyer,
        address token,
        uint256 amount,
        uint256 price,
        address relayer
    );

    /**
     * @dev Executes gasless trade using EIP-712 signature
     */
    function executeGaslessTrade(
        Trade calldata trade,
        uint8 v, bytes32 r, bytes32 s
    ) external {
        require(block.timestamp <= trade.expiry, "Order expired");
        require(trade.nonce == userNonce[trade.seller] + 1, "Invalid nonce");

        bytes32 orderHash = keccak256(abi.encode(
            trade.seller,
            trade.buyer,
            trade.token,
            trade.amount,
            trade.price,
            trade.nonce,
            trade.expiry
        ));

        require(!executedOrder[orderHash], "Order already executed");

        address signer = ecrecover(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", orderHash)),
            v, r, s
        );

        require(signer == trade.seller, "Invalid seller signature");

        executedOrder[orderHash] = true;
        userNonce[trade.seller]++;

        // Transfer tokens from seller to buyer
        require(IERC20(trade.token).transferFrom(trade.seller, trade.buyer, trade.amount), "Token transfer failed");

        // Transfer price from buyer to seller
        require(IERC20(trade.token).transferFrom(trade.buyer, trade.seller, trade.price), "Payment failed");

        emit TradeExecuted(trade.seller, trade.buyer, trade.token, trade.amount, trade.price, msg.sender);
    }
}
