// Demonstrating access control in Inco
import {euint256, ebool, e, inco} from "@inco/lightning/Lib.sol";

contract AccessControlExample {
    using e for *;
    
    mapping(address => euint256) private balances;
    
    function updateBalance(
        address user,
        euint256 newBalance
    ) public {
        // Update the balance
        balances[user] = newBalance;
        
        // CRITICAL: Grant access to the new handle
        
        // 1. Allow the user to see their own balance
        newBalance.allow(user);
        
        // 2. Allow the contract to use this balance in future transactions
        newBalance.allowThis(); // Equivalent to newBalance.allow(address(this))
        
        // Note: Forgetting allowThis() will make the balance unusable
        // in future contract calls!
    }
    
    function transferWithAccessControl(
        address from,
        address to,
        euint256 amount
    ) public returns (ebool) {
        // Check if caller has access to the amount handle
        require(
            msg.sender.isAllowed(amount),
            "Unauthorized value handle access"
        );
        
        // Check balance (encrypted comparison)
        ebool hasSufficientBalance = balances[from].ge(amount);
        
        // Select amount to transfer
        euint256 transferredAmount = hasSufficientBalance.select(
            amount,
            uint256(0).asEuint256()
        );
        
        // Update balances
        euint256 newFromBalance = balances[from].sub(transferredAmount);
        euint256 newToBalance = balances[to].add(transferredAmount);
        
        balances[from] = newFromBalance;
        balances[to] = newToBalance;
        
        // Grant access to updated balances
        newFromBalance.allow(from);
        newToBalance.allow(to);
        newFromBalance.allowThis();
        newToBalance.allowThis();
        
        // Let caller know if transfer succeeded
        hasSufficientBalance.allow(msg.sender);
        
        return hasSufficientBalance;
    }
    
    // Example showing the dual-function pattern
    function transfer(
        address to,
        bytes memory amountInput
    ) external payable returns (ebool) {
        require(msg.value >= inco.getFee() * 1, "Fee Not Paid");
        euint256 amount = amountInput.newEuint256(msg.sender);
        return transfer(to, amount);
    }
    
    function transfer(
        address to,
        euint256 amount
    ) public returns (ebool) {
        require(
            msg.sender.isAllowed(amount),
            "Unauthorized value handle access"
        );
        return transferWithAccessControl(msg.sender, to, amount);
    }
}
