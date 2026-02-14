const { expect } = require("chai");
const hre = require("hardhat");
const { ethers } = hre;

describe("SkillsMarketplace", function () {
  let SkillsMarketplace;
  let skillsMarketplace;
  let owner;
  let worker1;
  let worker2;
  let employer1;
  let employer2;

  beforeEach(async function () {
    SkillsMarketplace = await ethers.getContractFactory("SkillsMarketplace");
    [owner, worker1, worker2, employer1, employer2] = await ethers.getSigners();
    skillsMarketplace = await SkillsMarketplace.deploy();
  });

  describe("Worker Registration", function () {
    it("Should register a worker", async function () {
      await skillsMarketplace.connect(worker1).registerWorker("web development");
      const worker = await skillsMarketplace.workers(worker1.address);
      
      expect(worker.skill).to.equal("web development");
      expect(worker.isRegistered).to.be.true;
    });

    it("Should prevent duplicate registration", async function () {
      await skillsMarketplace.connect(worker1).registerWorker("web development");
      
      await expect(
        skillsMarketplace.connect(worker1).registerWorker("blockchain")
      ).to.be.revertedWith("Worker already registered");
    });
  });

  describe("Gig Management", function () {
    it("Should allow posting a gig with bounty", async function () {
      const bounty = ethers.parseEther("0.1");
      
      await skillsMarketplace.connect(employer1).postGig(
        "Build a website",
        "web development",
        { value: bounty }
      );

      const gigCount = await skillsMarketplace.gigCount();
      const gig = await skillsMarketplace.gigs(gigCount);
      
      expect(gigCount).to.equal(1);
      expect(gig.employer).to.equal(employer1.address);
      expect(gig.description).to.equal("Build a website");
      expect(gig.skillRequired).to.equal("web development");
      expect(gig.bounty).to.equal(bounty);
    });

    it("Should prevent posting gig without bounty", async function () {
      await expect(
        skillsMarketplace.connect(employer1).postGig(
          "Build a website",
          "web development",
          { value: 0 }
        )
      ).to.be.revertedWith("Bounty must be greater than 0");
    });
  });

  describe("Gig Application", function () {
    it("Should allow worker to apply for gig", async function () {
      // Post gig
      await skillsMarketplace.connect(employer1).postGig(
        "Build a website",
        "web development",
        { value: ethers.parseEther("0.1") }
      );

      // Register worker
      await skillsMarketplace.connect(worker1).registerWorker("web development");

      // Apply for gig
      await skillsMarketplace.connect(worker1).applyForGig(1);

      const hasApplied = await skillsMarketplace.hasApplied(1, worker1.address);
      expect(hasApplied).to.be.true;
    });

    it("Should prevent application from unregistered worker", async function () {
      // Post gig
      await skillsMarketplace.connect(employer1).postGig(
        "Build a website",
        "web development",
        { value: ethers.parseEther("0.1") }
      );

      await expect(
        skillsMarketplace.connect(worker1).applyForGig(1)
      ).to.be.revertedWith("Worker not registered");
    });

    it("Should prevent application with wrong skill", async function () {
      // Post gig
      await skillsMarketplace.connect(employer1).postGig(
        "Build a website",
        "web development",
        { value: ethers.parseEther("0.1") }
      );

      // Register worker with wrong skill
      await skillsMarketplace.connect(worker1).registerWorker("blockchain");

      await expect(
        skillsMarketplace.connect(worker1).applyForGig(1)
      ).to.be.revertedWith("Worker does not have required skill");
    });
  });

  describe("Work Submission and Payment", function () {
    it("Should allow worker to submit work and get paid", async function () {
      const bounty = ethers.parseEther("0.1");
      
      // Post gig
      await skillsMarketplace.connect(employer1).postGig(
        "Build a website",
        "web development",
        { value: bounty }
      );

      // Register and apply
      await skillsMarketplace.connect(worker1).registerWorker("web development");
      await skillsMarketplace.connect(worker1).applyForGig(1);

      // Submit work
      await skillsMarketplace.connect(worker1).submitWork(1, "https://example.com/work");

      // Approve and pay
      const initialBalance = await ethers.provider.getBalance(worker1.address);
      await skillsMarketplace.connect(employer1).approveAndPay(1, worker1.address);
      const finalBalance = await ethers.provider.getBalance(worker1.address);

      // Check worker received payment
      expect(finalBalance).to.be.greaterThan(initialBalance);
    });

    it("Should prevent payment from non-employer", async function () {
      const bounty = ethers.parseEther("0.1");
      
      await skillsMarketplace.connect(employer1).postGig(
        "Build a website",
        "web development",
        { value: bounty }
      );

      await skillsMarketplace.connect(worker1).registerWorker("web development");
      await skillsMarketplace.connect(worker1).applyForGig(1);
      await skillsMarketplace.connect(worker1).submitWork(1, "https://example.com/work");

      await expect(
        skillsMarketplace.connect(employer2).approveAndPay(1, worker1.address)
      ).to.be.revertedWith("Only employer can approve work");
    });
  });
});