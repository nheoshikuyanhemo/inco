// Demonstrating best practices for Inco dApps
import {euint256, ebool, e, inco} from "@inco/lightning/Lib.sol";
import {DecryptionAttestation} from "@inco/lightning/src/lightning-parts/DecryptionAttester.types.sol";

contract BestPracticesExample {
    using e for *;
    
    // ====== PRACTICE 1: Always check allowance over inputs ======
    
    // External function for off-chain inputs
    function submitEncryptedInput(
        bytes memory input
    ) external payable returns (ebool) {
        require(msg.value >= inco.getFee() * 1, "Fee Not Paid");
        euint256 value = input.newEuint256(msg.sender);
        return _processInput(value);
    }
    
    // Public function for existing e-variables (from other contracts)
    function submitEncryptedInput(
        euint256 value
    ) public returns (ebool) {
        // ALWAYS check allowance for e-variable inputs
        require(
            msg.sender.isAllowed(value),
            "Unauthorized value handle access"
        );
        return _processInput(value);
    }
    
    // ====== PRACTICE 2: Don't lose access over ciphertexts ======
    
    mapping(address => euint256) public balances;
    
    function updateBalance(address user, euint256 newBalance) public {
        // Update the balance
        balances[user] = newBalance;
        
        // CRITICAL: Grant access after update
        newBalance.allow(user);           // User can see their balance
        newBalance.allowThis();           // Contract can use it later
        
        // Forgetting these calls will break future functionality!
    }
    
    // ====== PRACTICE 3: Always verify handles in attestations ======
    
    euint256 public secretNumber;
    
    function submitAttestation(
        DecryptionAttestation memory decryption,
        bytes[] memory signatures
    ) external {
        // 1. Verify signatures
        require(
            inco.incoVerifier().isValidDecryptionAttestation(decryption, signatures),
            "Invalid Signature"
        );
        
        // 2. CRITICAL: Verify handle matches expected ciphertext
        require(
            euint256.unwrap(secretNumber) == decryption.handle,
            "Handle mismatch"
        );
        
        // 3. Now safely use the decrypted value
        uint256 decryptedNumber = uint256(decryption.value);
        
        // ... process decryptedNumber
    }
    
    // ====== PRACTICE 4: Be careful with information leakage ======
    
    // Example of potential information leakage
    mapping(address => euint256) private bids;
    euint256 private currentHighestBid;
    eaddress private currentHighestBidder;
    
    function placeBid(bytes memory bidAmountInput) external payable {
        require(msg.value >= inco.getFee() * 1, "Fee Not Paid");
        
        euint256 bidAmount = bidAmountInput.newEuint256(msg.sender);
        bids[msg.sender] = bidAmount;
        
        // WARNING: This could leak information!
        // An observer could deduce the current highest bid
        // by watching when they become the highest bidder
        
        // Better approach: Use commit-reveal scheme or batch processing
    }
    
    // ====== Helper function ======
    
    function _processInput(euint256 value) private returns (ebool) {
        // Process the input and return result
        ebool isValid = value.gt(uint256(0).asEuint256());
        isValid.allow(msg.sender);
        return isValid;
    }
    
    // ====== Warning about delegatecall ======
    // A contract being delegatecalled can decrypt any ciphertext
    // your contract holds or share access to it.
    // ONLY use delegatecall with fully trusted contracts!
}
