// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SecureLottery
 * @dev An advanced lottery smart contract with security features
 * @notice PART 2 - Secure Lottery (MANDATORY)
 */
contract SecureLottery {
    
    address public owner;
    uint256 public lotteryId;
    uint256 public lotteryStartTime;
    bool public isPaused;
    
    // TODO: Define additional state variables
    // Consider:
    // - How will you track entries?
    // - How will you store player information?
    // - What data structure for managing the pot?

    uint256 public minimumEntryFee;
    uint256 public totalEntries;
    address[] public entries;
    mapping(address => uint256) public playerEntryCount;
    mapping(address => bool) public uniquePlayers;
    uint256 public uniquePlayerCount;
    
    // Events
    event PlayerEntered(address indexed player, uint256 entryCount, uint256 totalEntries);
    event WinnerSelected(address indexed winner, uint256 amount, uint256 lotteryId);
    event LotteryPaused();
    event LotteryUnpaused();
    
    constructor() {
        owner = msg.sender;
        lotteryId = 1;
        lotteryStartTime = block.timestamp;
        isPaused = false;
        minimumEntryFee = 0.01 ether;
        totalEntries = 0;
        uniquePlayerCount = 0;
    }
    
    // TODO: Implement entry function
    // Requirements:
    // - Players pay minimum 0.01 ETH to enter
    // - Track each entry (not just unique addresses)
    // - Allow multiple entries per player
    // - Emit event with player address and entry count
    function enter() public payable whenNotPaused {
         // Your implementation here
        // Validation: Check minimum entry amount
        // Validation: Check if lottery is active
        require(msg.value >= minimumEntryFee, "Minimum entry fee is 0.01 ETH");
        require(block.timestamp - lotteryStartTime < 24 hours, "Lottery has ended");
        
        // Calculate number of entries based on eth sent
        uint256 numberOfEntries = msg.value / minimumEntryFee;
        
        // Add entries
        for (uint256 i = 0; i < numberOfEntries; i++) {
            entries.push(msg.sender);
            totalEntries++;
        }
        
        // Update player entry count and unique players
        if (!uniquePlayers[msg.sender]) {
            uniquePlayers[msg.sender] = true;
            uniquePlayerCount++;
        }
        playerEntryCount[msg.sender] += numberOfEntries;
        
        emit PlayerEntered(msg.sender, playerEntryCount[msg.sender], totalEntries);
    }
    
    // TODO: Implement winner selection function
    // Requirements:
    // - Only owner can trigger
    // - Select winner from TOTAL entries (not unique players)
    // - Winner gets 90% of pot, owner gets 10% fee
    // - Use a secure random mechanism (better than block.timestamp)
    // - Require at least 3 unique players
    // - Require lottery has been active for 24 hours
    function selectWinner() public onlyOwner {
        require(block.timestamp - lotteryStartTime >= 24 hours, "Lottery not yet ended");
        require(uniquePlayerCount >= 3, "Need at least 3 unique players");
        require(totalEntries > 0, "No entries in lottery");
        
        // random winner using secure mechanism (blockhash + block.timestamp + lotteryId)
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(
            blockhash(block.number - 1),
            block.timestamp,
            lotteryId,
            totalEntries
        )));
        
        uint256 winnerIndex = randomNumber % totalEntries;
        address winner = entries[winnerIndex];
        
        // payout
        uint256 pot = address(this).balance;
        uint256 winnerAmount = (pot * 90) / 100;
        uint256 ownerFee = pot - winnerAmount;
        
        // Transfer funds
        payable(winner).transfer(winnerAmount);
        payable(owner).transfer(ownerFee);
        
        emit WinnerSelected(winner, winnerAmount, lotteryId);
        
        resetLottery();
    }
    
    // TODO: Implement circuit breaker (pause/unpause)
    // Requirements:
    // - Owner can pause lottery in emergency
    // - Owner can unpause lottery
    // - When paused, no entries allowed
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
    
    modifier whenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }
    
    function pause() public onlyOwner {
        isPaused = true;
        emit LotteryPaused();
    }
    
    function unpause() public onlyOwner {
        isPaused = false;
        emit LotteryUnpaused();
    }
    
    // TODO: Helper/View functions
    // - Get current pot balance
    // - Get player entry count
    // - Check if lottery is active
    // - Get unique player count
    function getCurrentPot() public view returns (uint256) {
        return address(this).balance;
    }
    
    function getPlayerEntryCount(address player) public view returns (uint256) {
        return playerEntryCount[player];
    }
    
    function isLotteryActive() public view returns (bool) {
        return block.timestamp - lotteryStartTime < 24 hours && !isPaused;
    }
    
    function getUniquePlayerCount() public view returns (uint256) {
        return uniquePlayerCount;
    }
    
    function getTotalEntries() public view returns (uint256) {
        return totalEntries;
    }
    
    // Internal function to reset lottery
    function resetLottery() internal {
        lotteryId++;
        lotteryStartTime = block.timestamp;
        totalEntries = 0;
        uniquePlayerCount = 0;
        delete entries;
        
    
        entries = new address[](0);
        
    }
    
    // Fallback function to accept ETH
    receive() external payable {
        if (msg.value >= minimumEntryFee && !isPaused && block.timestamp - lotteryStartTime < 24 hours) {
            enter();
        }
    }
}