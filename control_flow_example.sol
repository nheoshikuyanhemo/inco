// Demonstrating control flow with select statement
import {euint256, ebool, e} from "@inco/lightning/Lib.sol";

contract ControlFlowExample {
    using e for *;
    
    mapping(address => euint256) public balanceOf;
    
    // Multiplexer design pattern with select
    function confidentialTransfer(
        address to,
        euint256 value
    ) public returns (ebool success) {
        // Check if sender has enough balance (encrypted comparison)
        success = balanceOf[msg.sender].ge(value);
        
        // Select amount to transfer: value if true, 0 if false
        euint256 transferredValue = success.select(
            value,                     // If balance >= value
            uint256(0).asEuint256()   // If balance < value
        );
        
        // Update balances (always executes, but might transfer 0)
        euint256 senderNewBalance = balanceOf[msg.sender].sub(transferredValue);
        euint256 receiverNewBalance = balanceOf[to].add(transferredValue);
        
        balanceOf[msg.sender] = senderNewBalance;
        balanceOf[to] = receiverNewBalance;
        
        // Grant access to new balances
        senderNewBalance.allow(msg.sender);
        receiverNewBalance.allow(to);
        senderNewBalance.allowThis();
        receiverNewBalance.allowThis();
        
        return success;
    }
    
    // Another example: access control
    function confidentialAccessCheck(
        address user,
        ebool isAuthorized,
        euint256 sensitiveData
    ) public returns (euint256) {
        // Select data based on authorization
        euint256 result = isAuthorized.select(
            sensitiveData,            // Authorized users get the data
            uint256(0).asEuint256()   // Others get 0
        );
        
        result.allow(user);
        return result;
    }
}
