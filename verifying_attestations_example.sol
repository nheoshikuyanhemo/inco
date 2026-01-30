// Demonstrating verification of attested results
import {euint256, ebool, e, inco} from "@inco/lightning/Lib.sol";
import {DecryptionAttestation} from "@inco/lightning/src/lightning-parts/DecryptionAttester.types.sol";
import {asBool} from "@inco/lightning/src/shared/TypeUtils.sol";

contract VerifyingAttestationsExample {
    using e for *;
    
    // Example 1: Attested Decrypt verification
    struct GatedContent {
        euint256 secretData;
        ebool accessGranted;
    }
    
    mapping(address => GatedContent) private userContent;
    
    function submitDecryptionAttestation(
        DecryptionAttestation memory decryption,
        bytes[] memory signatures
    ) external {
        // 1. Verify covalidator signatures
        require(
            inco.incoVerifier().isValidDecryptionAttestation(decryption, signatures),
            "Invalid signature"
        );
        
        // 2. Verify handle matches user's secret data
        GatedContent storage content = userContent[msg.sender];
        require(
            euint256.unwrap(content.secretData) == decryption.handle,
            "Handle mismatch"
        );
        
        // 3. Check the decrypted value
        require(
            asBool(decryption.value) == true,
            "Decryption value check failed"
        );
        
        // 4. Grant access based on successful verification
        content.accessGranted = e.asEbool(true);
        content.accessGranted.allow(msg.sender);
    }
    
    // Example 2: Attested Compute verification (credit check)
    mapping(address => euint256) private creditScores;
    
    function submitCreditCheck(
        DecryptionAttestation memory decryption,
        bytes[] memory signatures
    ) external {
        // 1. Verify signatures
        require(
            inco.incoVerifier().isValidDecryptionAttestation(decryption, signatures),
            "Invalid signature"
        );
        
        // 2. Recompute the expected handle on-chain
        euint256 userScore = creditScores[msg.sender];
        ebool expectedResult = userScore.ge(700); // creditScore >= 700
        require(
            ebool.unwrap(expectedResult) == decryption.handle,
            "Computed handle mismatch"
        );
        
        // 3. Check the attested result is true
        require(
            asBool(decryption.value) == true,
            "Credit check failed"
        );
        
        // 4. Proceed with approved action
        _grantLoan(msg.sender);
    }
    
    // Example 3: Attested Reveal verification
    euint256 public revealedValue;
    bool public isValueRevealed;
    
    function revealSecret() public {
        // Make value public
        e.reveal(revealedValue);
        isValueRevealed = true;
    }
    
    function submitRevealedAttestation(
        DecryptionAttestation memory decryption,
        bytes[] memory signatures
    ) external {
        require(isValueRevealed, "Value not revealed yet");
        
        // 1. Verify signatures
        require(
            inco.incoVerifier().isValidDecryptionAttestation(decryption, signatures),
            "Invalid signature"
        );
        
        // 2. Verify handle matches the revealed value
        require(
            euint256.unwrap(revealedValue) == decryption.handle,
            "Handle mismatch"
        );
        
        // 3. Use the plaintext value
        uint256 plaintextValue = uint256(decryption.value);
        
        // ... use the plaintext value
    }
    
    function _grantLoan(address user) private {
        // Implementation for granting loan
    }
}
