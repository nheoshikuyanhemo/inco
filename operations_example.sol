// Demonstrating operations on encrypted data
import {euint256, ebool, e} from "@inco/lightning/Lib.sol";

contract OperationsExample {
    using e for *;
    
    // Mathematical operations
    function mathOperations() public {
        euint256 a = e.asEuint256(2);
        euint256 b = e.asEuint256(3);
        
        // All return euint256
        euint256 sum = a.add(b);        // 5
        euint256 difference = a.sub(b); // -1 (encrypted)
        euint256 product = a.mul(b);    // 6
        euint256 quotient = a.div(b);   // 0
        
        // Bitwise operations
        euint256 bitAnd = a.and(b);     // 2 & 3 = 2
        euint256 bitOr = a.or(b);       // 2 | 3 = 3
        euint256 bitXor = a.xor(b);     // 2 ^ 3 = 1
    }
    
    // Comparison operations
    function comparisonOperations() public returns (ebool) {
        euint256 a = e.asEuint256(5);
        euint256 b = e.asEuint256(3);
        
        ebool isEqual = a.eq(b);        // false
        ebool notEqual = a.ne(b);       // true
        ebool greaterOrEqual = a.ge(b); // true
        ebool greaterThan = a.gt(b);    // true
        ebool lessOrEqual = a.le(b);    // false
        ebool lessThan = a.lt(b);       // false
        
        // Min/Max
        euint256 minimum = a.min(b);    // 3
        euint256 maximum = a.max(b);    // 5
        
        return greaterThan;
    }
    
    // Random number generation
    function generateRandom() public returns (euint256) {
        // Generate random number
        euint256 randomNumber = e.rand();
        
        // Generate bounded random number
        euint256 boundedRandom = e.randBounded(100); // 0-99
        
        // Generate bounded random with encrypted bound
        euint256 encryptedBound = e.asEuint256(50);
        euint256 boundedRandomEncrypted = e.randBounded(encryptedBound);
        
        return boundedRandom;
    }
    
    // Type conversions
    function typeConversions() public {
        // To encrypted types
        euint256 encryptedUint = e.asEuint256(42);
        ebool encryptedBool = e.asEbool(true);
        
        // Between encrypted types
        ebool fromUint = e.asEbool(encryptedUint);
        euint256 fromBool = e.asEuint256(encryptedBool);
    }
    
    // Reveal functions
    function revealValue(euint256 secretValue) public {
        // Makes encrypted value public
        e.reveal(secretValue);
    }
}
