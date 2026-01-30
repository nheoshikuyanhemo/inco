// Example demonstrating handles in Inco
import {euint256, ebool, e} from "@inco/lightning/Lib.sol";

contract HandlesExample {
    using e for *;
    
    // Handles are bytes32 identifiers
    // euint256 is bytes32, ebool is bytes32, eaddress is bytes32
    
    mapping(address => euint256) public balanceOf;
    
    function demonstrateHandle() public view returns (bytes32) {
        // This returns a handle (bytes32), not the actual balance
        return euint256.unwrap(balanceOf[msg.sender]);
    }
}
