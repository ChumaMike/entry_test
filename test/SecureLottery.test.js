const { expect } = require("chai");
const hre = require("hardhat");
const { ethers } = hre;

describe("SecureLottery", function () {
  let SecureLottery;
  let secureLottery;
  let owner;
  let player1;
  let player2;
  let player3;
  let player4;

  beforeEach(async function () {
    SecureLottery = await ethers.getContractFactory("SecureLottery");
    [owner, player1, player2, player3, player4] = await ethers.getSigners();
    secureLottery = await SecureLottery.deploy();
  });

  describe("Lottery Operations", function () {
    it("Should allow player to enter with minimum fee", async function () {
      const entryFee = ethers.parseEther("0.01");
      
      await secureLottery.connect(player1).enter({ value: entryFee });
      
      const entryCount = await secureLottery.getPlayerEntryCount(player1.address);
      const totalEntries = await secureLottery.getTotalEntries();
      
      expect(entryCount).to.equal(1);
      expect(totalEntries).to.equal(1);
    });

    it("Should allow multiple entries with higher fee", async function () {
      const entryFee = ethers.parseEther("0.03");
      
      await secureLottery.connect(player1).enter({ value: entryFee });
      
      const entryCount = await secureLottery.getPlayerEntryCount(player1.address);
      const totalEntries = await secureLottery.getTotalEntries();
      
      expect(entryCount).to.equal(3);
      expect(totalEntries).to.equal(3);
    });

    it("Should prevent entry with less than minimum fee", async function () {
      const smallFee = ethers.parseEther("0.005");
      
      await expect(
        secureLottery.connect(player1).enter({ value: smallFee })
      ).to.be.revertedWith("Minimum entry fee is 0.01 ETH");
    });
  });

  describe("Lottery Status", function () {
    it("Should pause and unpause lottery", async function () {
      await secureLottery.connect(owner).pause();
      expect(await secureLottery.isPaused()).to.be.true;

      await secureLottery.connect(owner).unpause();
      expect(await secureLottery.isPaused()).to.be.false;
    });

    it("Should prevent entry when paused", async function () {
      await secureLottery.connect(owner).pause();
      
      const entryFee = ethers.parseEther("0.01");
      await expect(
        secureLottery.connect(player1).enter({ value: entryFee })
      ).to.be.revertedWith("Contract is paused");
    });
  });

  describe("Winner Selection", function () {
    it("Should select winner after 24 hours with minimum players", async function () {
      const entryFee = ethers.parseEther("0.01");
      
      // Enter 3 players
      await secureLottery.connect(player1).enter({ value: entryFee });
      await secureLottery.connect(player2).enter({ value: entryFee });
      await secureLottery.connect(player3).enter({ value: entryFee });

      // Fast forward 24 hours
      await ethers.provider.send("evm_increaseTime", [24 * 60 * 60]);
      await ethers.provider.send("evm_mine");

      // Select winner
      await secureLottery.connect(owner).selectWinner();

      // Check lottery reset
      const lotteryId = await secureLottery.lotteryId();
      expect(lotteryId).to.equal(2);
    });

    it("Should prevent winner selection before 24 hours", async function () {
      const entryFee = ethers.parseEther("0.01");
      
      await secureLottery.connect(player1).enter({ value: entryFee });
      await secureLottery.connect(player2).enter({ value: entryFee });
      await secureLottery.connect(player3).enter({ value: entryFee });

      await expect(
        secureLottery.connect(owner).selectWinner()
      ).to.be.revertedWith("Lottery not yet ended");
    });

    it("Should prevent winner selection with less than 3 players", async function () {
      const entryFee = ethers.parseEther("0.01");
      
      await secureLottery.connect(player1).enter({ value: entryFee });
      await secureLottery.connect(player2).enter({ value: entryFee });

      await ethers.provider.send("evm_increaseTime", [24 * 60 * 60]);
      await ethers.provider.send("evm_mine");

      await expect(
        secureLottery.connect(owner).selectWinner()
      ).to.be.revertedWith("Need at least 3 unique players");
    });
  });

  describe("Pot and Fees", function () {
    it("Should calculate pot correctly", async function () {
      const entryFee = ethers.parseEther("0.01");
      
      await secureLottery.connect(player1).enter({ value: entryFee });
      await secureLottery.connect(player2).enter({ value: entryFee });
      await secureLottery.connect(player3).enter({ value: entryFee });

      const pot = await secureLottery.getCurrentPot();
      const expectedPot = ethers.parseEther("0.03");
      
      expect(pot).to.equal(expectedPot);
    });

    it("Should distribute winnings correctly", async function () {
      const entryFee = ethers.parseEther("0.01");
      
      await secureLottery.connect(player1).enter({ value: entryFee });
      await secureLottery.connect(player2).enter({ value: entryFee });
      await secureLottery.connect(player3).enter({ value: entryFee });

      await ethers.provider.send("evm_increaseTime", [24 * 60 * 60]);
      await ethers.provider.send("evm_mine");

      const initialOwnerBalance = await ethers.provider.getBalance(owner.address);
      const initialPlayer1Balance = await ethers.provider.getBalance(player1.address);

      await secureLottery.connect(owner).selectWinner();

      const finalOwnerBalance = await ethers.provider.getBalance(owner.address);
      const finalPlayer1Balance = await ethers.provider.getBalance(player1.address);

      // Owner should receive 10% fee
      expect(finalOwnerBalance).to.be.greaterThan(initialOwnerBalance);
    });
  });
});