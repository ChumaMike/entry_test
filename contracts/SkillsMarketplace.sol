// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SkillsMarketplace
 * @dev A decentralised marketplace for skills and gigs
 * @notice PART 1 - Skills Marketplace (MANDATORY)
 */
contract SkillsMarketplace {
    
    // TODO: Define your state variables here
    // Consider:
    // - How will you track workers and their skills?
    // - How will you store gig information?
    // - How will you manage payments?
    address public owner;
    uint256 public gigCount;
    
    struct Worker {
        string skill;
        bool isRegistered;
    }
    mapping(address => Worker) public workers;
    
    // Gig struct and mapping
    struct Gig {
        address employer;
        string description;
        string skillRequired;
        uint256 bounty;
        address selectedWorker;
        string submissionUrl;
        bool isCompleted;
        bool isPaid;
    }
    mapping(uint256 => Gig) public gigs;
    
    mapping(uint256 => mapping(address => bool)) public gigApplications;
    
    // Events
    event WorkerRegistered(address indexed worker, string skill);
    event GigPosted(uint256 indexed gigId, address indexed employer, string description, string skillRequired, uint256 bounty);
    event GigApplied(uint256 indexed gigId, address indexed worker);
    event WorkSubmitted(uint256 indexed gigId, address indexed worker, string submissionUrl);
    event WorkApproved(uint256 indexed gigId, address indexed worker, uint256 amount);
    
    constructor() {
        owner = msg.sender;
        gigCount = 0;
    }
    
    // Implement registerWorker function
    function registerWorker(string memory skill) public {
        require(!workers[msg.sender].isRegistered, "Worker already registered");
        
        workers[msg.sender] = Worker({
            skill: skill,
            isRegistered: true
        });
        
        emit WorkerRegistered(msg.sender, skill);
    }
    
    // TODO: Implement postGig function
    // Requirements:
    // - Employers post gigs with bounty (msg.value)
    // - Store gig description and required skill
    // - Ensure ETH is sent with the transaction
    // - Emit an event when gig is posted
    function postGig(string memory description, string memory skillRequired) public payable {
        // Your implementation here
        // Think: How do you safely hold the ETH until work is approved?
        require(msg.value > 0, "Bounty must be greater than 0");
        
        gigCount++;
        gigs[gigCount] = Gig({
            employer: msg.sender,
            description: description,
            skillRequired: skillRequired,
            bounty: msg.value,
            selectedWorker: address(0),
            submissionUrl: "",
            isCompleted: false,
            isPaid: false
        });
        
        emit GigPosted(gigCount, msg.sender, description, skillRequired, msg.value);
    }
    
    // TODO: Implement applyForGig function
    // Requirements:
    // - Workers can apply for gigs
    // - Check if worker has the required skill
    // - Prevent duplicate applications
    // - Emit an event
    function applyForGig(uint256 gigId) public {
        // Your implementation here
        require(gigId > 0 && gigId <= gigCount, "Invalid gig ID");
        require(workers[msg.sender].isRegistered, "Worker not registered");
        require(!gigApplications[gigId][msg.sender], "Already applied to this gig");
        require(keccak256(bytes(workers[msg.sender].skill)) == keccak256(bytes(gigs[gigId].skillRequired)), "Worker does not have required skill");
        require(gigs[gigId].selectedWorker == address(0), "Gig already has selected worker");
        require(!gigs[gigId].isCompleted, "Gig already completed");
        
        gigApplications[gigId][msg.sender] = true;
        
        emit GigApplied(gigId, msg.sender);
    }
    
    // TODO: Implement submitWork function
    // Requirements:
    // - Workers submit completed work (with proof/URL)
    // - Validate that worker applied for this gig
    // - Update gig status
    // - Emit an event
    function submitWork(uint256 gigId, string memory submissionUrl) public {
        // Your implemention here
        require(gigId > 0 && gigId <= gigCount, "Invalid gig ID");
        require(gigApplications[gigId][msg.sender], "Worker did not apply to this gig");
        require(gigs[gigId].selectedWorker == address(0) || gigs[gigId].selectedWorker == msg.sender, "Not selected worker");
        require(!gigs[gigId].isCompleted, "Gig already completed");
        
        gigs[gigId].selectedWorker = msg.sender;
        gigs[gigId].submissionUrl = submissionUrl;
        
        emit WorkSubmitted(gigId, msg.sender, submissionUrl);
    }
    
    // TODO: Implement approveAndPay function
    // Requirements:
    // - Only employer who posted gig can approve
    // - Transfer payment to worker
    // - CRITICAL: Implement reentrancy protection
    // - Update gig status to completed
    // - Emit an event
    function approveAndPay(uint256 gigId, address worker) public {
        // Your implementation here
        // Security: Use cehcks-effects-interaction pattern!
        require(gigId > 0 && gigId <= gigCount, "Invalid gig ID");
        require(msg.sender == gigs[gigId].employer, "Only employer can approve work");
        require(gigApplications[gigId][worker], "Worker did not apply to this gig");
        require(bytes(gigs[gigId].submissionUrl).length > 0, "No work submitted");
        require(!gigs[gigId].isPaid, "Work already paid");
        
        // Checks-Effects-Interactions pattern
        uint256 bounty = gigs[gigId].bounty;
        gigs[gigId].isCompleted = true;
        gigs[gigId].isPaid = true;
        
        emit WorkApproved(gigId, worker, bounty);
        
        // Transfer payment
        payable(worker).transfer(bounty);
    }
    
    // Helper functions you might need:
    // - Function to get gig details
    // - Function to check worker registration
    // - Function to get all gigs
    function getGigDetails(uint256 gigId) public view returns (
        address employer,
        string memory description,
        string memory skillRequired,
        uint256 bounty,
        address selectedWorker,
        string memory submissionUrl,
        bool isCompleted,
        bool isPaid
    ) {
        Gig storage gig = gigs[gigId];
        return (
            gig.employer,
            gig.description,
            gig.skillRequired,
            gig.bounty,
            gig.selectedWorker,
            gig.submissionUrl,
            gig.isCompleted,
            gig.isPaid
        );
    }
    
    function isWorkerRegistered(address worker) public view returns (bool) {
        return workers[worker].isRegistered;
    }
    
    function getWorkerSkill(address worker) public view returns (string memory) {
        return workers[worker].skill;
    }
    
    function hasApplied(uint256 gigId, address worker) public view returns (bool) {
        return gigApplications[gigId][worker];
    }
}