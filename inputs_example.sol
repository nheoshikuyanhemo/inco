// Examples of different input methods in Inco
import {euint256, ebool, eaddress, e, inco} from "@inco/lightning/Lib.sol";

contract InputsExample {
    using e for *;
    
    // Case 1: Off-chain encrypted input
    function transferFromOffchain(
        address to,
        bytes memory valueInput
    ) external payable returns (ebool) {
        // Pay fee for one ciphertext
        require(msg.value >= inco.getFee() * 1, "Fee Not Paid");
        
        // Convert encrypted input to handle
        euint256 value = valueInput.newEuint256(msg.sender);
        
        // Continue with logic...
        return e.asEbool(true);
    }
    
    // Case 2: On-chain known value
    function initialize() public {
        // Trivial encryption of known value
        uint256 initialBalance = 1000 * 1e9;
        euint256 encryptedBalance = initialBalance.asEuint256();
        
        // Store in mapping
        // ... logic
    }
    
    // Additional input types
    function setEncryptedAddress(
        bytes memory addressInput
    ) external payable {
        require(msg.value >= inco.getFee() * 1, "Fee Not Paid");
        eaddress authorizedAddr = addressInput.newEaddress(msg.sender);
        // ... logic
    }
    
    function setEncryptedBool(
        bytes memory flagInput
    ) external payable {
        require(msg.value >= inco.getFee() * 1, "Fee Not Paid");
        ebool flag = flagInput.newEbool(msg.sender);
        // ... logic
    }
}
