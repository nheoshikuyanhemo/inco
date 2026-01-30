// EList Preview Feature - Experimental, not for production
import {euint256, ebool, e, inco} from "@inco/lightning/src/Lib.sol";
import {ePreview, elist, ETypes} from "@inco/lightning-preview/src/Preview.Lib.sol";

contract EListExample {
    using e for *;
    
    // Important: Fee Payments and Access Control
    // Most operations require paying fees: msg.value >= inco.getFee() * ciphertextCount
    // Always call inco.allow() after creating/modifying an elist
    
    // ====== Creating ELists ======
    
    function createEmptyList() public returns (elist) {
        // Create empty list of euint256
        elist myList = ePreview.newEList(ETypes.Uint256);
        // myList = E([])
        
        // CRITICAL: Grant access
        inco.allow(elist.unwrap(myList), address(this));
        inco.allow(elist.unwrap(myList), msg.sender);
        
        return myList;
    }
    
    function createListFromHandles() public returns (elist) {
        // Create array of handles
        bytes32[] memory handles = new bytes32[](5);
        for (uint256 i = 0; i < 5; i++) {
            handles[i] = euint256.unwrap(e.asEuint256(i + 1));
        }
        
        // Create list from handles
        elist myList = ePreview.newEList(handles, ETypes.Uint256);
        // myList = E([1, 2, 3, 4, 5])
        
        // Grant access
        inco.allow(elist.unwrap(myList), address(this));
        inco.allow(elist.unwrap(myList), msg.sender);
        
        return myList;
    }
    
    function createListFromUserInputs(
        bytes[] memory inputs,
        ETypes listType,
        address user
    ) public payable returns (elist) {
        // Pay fee for each ciphertext
        require(msg.value >= inco.getFee() * inputs.length, "Fee not paid");
        
        // Create list from encrypted inputs
        elist list = ePreview.newEList(inputs, listType, user);
        
        // Grant access
        inco.allow(elist.unwrap(list), address(this));
        inco.allow(elist.unwrap(list), msg.sender);
        
        return list;
    }
    
    // ====== Basic Operations ======
    
    elist public currentList;
    
    function appendToList(bytes memory ctValue) public payable returns (elist) {
        require(msg.value >= inco.getFee(), "Fee not paid");
        
        // Convert ciphertext to handle
        euint256 value = e.newEuint256(ctValue, msg.sender);
        
        // Grant access to the value
        inco.allow(euint256.unwrap(value), address(this));
        inco.allow(euint256.unwrap(value), msg.sender);
        
        // Append to list
        currentList = ePreview.append(currentList, value);
        
        // Grant access to new list
        inco.allow(elist.unwrap(currentList), address(this));
        inco.allow(elist.unwrap(currentList), msg.sender);
        
        return currentList;
    }
    
    function getElement(uint16 index) public returns (euint256) {
        // Get element at plaintext index
        euint256 res = ePreview.getEuint256(currentList, index);
        
        // Grant access to the element
        inco.allow(euint256.unwrap(res), msg.sender);
        
        return res;
    }
    
    function getElementOr(
        bytes memory ctIndex,
        bytes memory ctDefaultValue
    ) public payable returns (euint256) {
        require(msg.value >= inco.getFee() * 2, "Fee not paid");
        
        // Encrypted index and default value
        euint256 index = e.newEuint256(ctIndex, msg.sender);
        euint256 defaultValue = e.newEuint256(ctDefaultValue, msg.sender);
        
        // Get element or default
        euint256 res = ePreview.getOr(currentList, index, defaultValue);
        
        // Grant access
        inco.allow(euint256.unwrap(res), msg.sender);
        
        return res;
    }
    
    // ====== List Manipulation ======
    
    function insertElement(uint256 index, euint256 value) public returns (elist) {
        // Insert element at position
        elist newList = ePreview.insert(currentList, index, value);
        
        // Update current list
        currentList = newList;
        
        // Grant access
        inco.allow(elist.unwrap(currentList), address(this));
        inco.allow(elist.unwrap(currentList), msg.sender);
        
        return currentList;
    }
    
    function setElement(uint256 index, euint256 newValue) public returns (elist) {
        // Set element at position
        elist newList = ePreview.set(currentList, index, newValue);
        
        // Update current list
        currentList = newList;
        
        // Grant access
        inco.allow(elist.unwrap(currentList), address(this));
        inco.allow(elist.unwrap(currentList), msg.sender);
        
        return currentList;
    }
    
    function concatenateLists(elist otherList) public returns (elist) {
        // Concatenate two lists
        elist concatenated = ePreview.concat(currentList, otherList);
        
        // Update current list
        currentList = concatenated;
        
        // Grant access
        inco.allow(elist.unwrap(currentList), address(this));
        inco.allow(elist.unwrap(currentList), msg.sender);
        
        return currentList;
    }
    
    // ====== Advanced Operations ======
    
    function sliceList(uint16 start, uint16 end) public returns (elist) {
        // Slice list (start inclusive, end exclusive)
        elist sliced = ePreview.slice(currentList, start, end);
        
        // Update current list
        currentList = sliced;
        
        // Grant access
        inco.allow(elist.unwrap(currentList), address(this));
        inco.allow(elist.unwrap(currentList), msg.sender);
        
        return currentList;
    }
    
    function sliceListWithEncryptedStart(
        bytes memory ctStart,
        uint16 length,
        bytes memory ctDefaultValue
    ) public payable returns (elist) {
        require(msg.value >= inco.getFee() * 2, "Fee not paid");
        
        // Encrypted start position and default value
        euint256 start = e.newEuint256(ctStart, msg.sender);
        euint256 defaultValue = e.newEuint256(ctDefaultValue, msg.sender);
        
        // Slice with encrypted start
        elist sliced = ePreview.sliceLen(currentList, start, length, defaultValue);
        
        // Update current list
        currentList = sliced;
        
        // Grant access
        inco.allow(elist.unwrap(currentList), address(this));
        inco.allow(elist.unwrap(currentList), msg.sender);
        
        return currentList;
    }
    
    function createRange(uint16 start, uint16 end) public returns (elist) {
        // Create list from range
        elist rangeList = ePreview.range(start, end);
        
        // Grant access
        inco.allow(elist.unwrap(rangeList), address(this));
        inco.allow(elist.unwrap(rangeList), msg.sender);
        
        return rangeList;
    }
    
    function reverseList() public returns (elist) {
        // Reverse list
        elist reversed = ePreview.reverse(currentList);
        
        // Update current list
        currentList = reversed;
        
        // Grant access
        inco.allow(elist.unwrap(currentList), address(this));
        inco.allow(elist.unwrap(currentList), msg.sender);
        
        return currentList;
    }
    
    function shuffleList() public payable returns (elist) {
        require(msg.value >= inco.getFee(), "Fee not paid");
        
        // Shuffle list deterministically
        elist shuffled = ePreview.shuffle(currentList);
        
        // Update current list
        currentList = shuffled;
        
        // Grant access
        inco.allow(elist.unwrap(currentList), address(this));
        
        return currentList;
    }
    
    // ====== Utility Functions ======
    
    function getListLength() public view returns (uint16) {
        // List length is PUBLIC information
        return ePreview.length(currentList);
    }
    
    function getListType() public view returns (ETypes) {
        return ePreview.listTypeOf(currentList);
    }
    
    // ====== Important Notes ======
    
    // 1. elist handles are IMMUTABLE - operations return new handles
    // 2. List length is ALWAYS PUBLIC
    // 3. Always call inco.allow() after operations
    // 4. Pay required fees for operations with encrypted inputs
    // 5. This is PREVIEW feature - not for production use
}
