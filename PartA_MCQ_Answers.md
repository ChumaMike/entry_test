# Part A: MCQ Answers

**Status:** [In Progress / Submitted]  

---

## Instructions
**COMPLETE ALL QUESTIONS FOR BOTH PART 1 AND PART 2 BELOW**

---

## PART 1: Agricultural Marketplace (Real-World African Context)

**Scenario:** You are hired as a blockchain developer to build a decentralised agricultural marketplace for African farmers. The platform must:

- Allow farmers to list produce as NFTs with quality certificates  
- Enable buyers to swap tokens for produce using a DEX  
- Store farmer reputation scores transparently  
- Process payments without intermediaries  

---

### Question 1: Architecture Decision (Technical Reasoning)

**Which combination of technologies demonstrates the best understanding of blockchain fundamentals for this use case?**

- **A)** Use ERC-721 for each produce item, build a centralised database for reputation, and integrate Binance for payments because CEXs have better liquidity.  
- **B)** Use ERC-1155 for produce items (enabling batch listings from farmers), implement reputation as on-chain mappings in the marketplace smart contract, and integrate with a DEX like Uniswap for direct farmer-to-buyer swaps to minimise intermediaries.  
- **C)** Use ERC-721 exclusively, store all data off-chain for gas savings, and require buyers to use MetaMask with manual price negotiations.  
- **D)** Build everything as separate NFT collections with no DEX integration since farmers won't understand DeFi protocols.  

**Your Answer:** [B]  

**Your Reasoning:**  
[2–3 sentences explaining why you chose this answer. What makes it the best choice?]  
Using ERC-1155 and implementing a reputation on-chain mappings helps make information more public for anyone. Anyone can see their information whenever they would like to. Integrating with Uniswap helps make transaction a lot faster and easier to do and they are kept track of for everyone to see, not just a certain company. 
---

### Question 2: Cost Optimisation (Practical Aptitude)

A farmer wants to list 50 bags of maize. Gas costs are:

- **ERC-721:** 100,000 gas per NFT mint  
- **ERC-1155:** 150,000 gas for first mint + 5,000 gas per additional item in batch  

**Current gas price:** 20 gwei  
**1 ETH = $3,000**

**What is the gas cost difference between ERC-721 and ERC-1155 for listing 50 items?**

- **A)** ERC-721 is cheaper by $15  
- **B)** ERC-1155 is cheaper by approximately $27  
- **C)** They cost exactly the same  
- **D)** ERC-1155 is cheaper by approximately $54  

**Your Answer:** [B]  

**Your Calculation/Reasoning:**  

- ERC-721 cost = 50 items × 100,000 gas = 5,000,000 gas  
  Cost in ETH = 5,000,000 × 20 gwei = 100,000,000,000,000,000 wei = 0.1 ETH  
  Cost in USD = 0.1 ETH × $3,000/ETH = $300  

- ERC-1155 cost = 150,000 gas (first mint) + 49 items × 5,000 gas = 150,000 + 245,000 = 395,000 gas  
  Cost in ETH = 395,000 × 20 gwei = 7,900,000,000,000,000 wei = 0.0079 ETH  
  Cost in USD = 0.0079 ETH × $3,000/ETH ≈ $23.70  

It will help limit the price since it is still blowing up in Africa.

---
### Question 3: Value Proposition Explanation (Communication & Thinking)

A farmer asks: *"Why can't we just use a normal website with a database?"*

**Which response demonstrates understanding of blockchain's actual value (not just its technology)?**

- **A)** "Blockchain is the future; everyone should use it."  
- **B)** "With blockchain, no middleman can manipulate your pricing or payment records. If a buyer claims they paid but you didn't receive funds, the blockchain provides immutable proof. Plus, your reputation score can follow you to other platforms since it's on-chain – it's your data, not the platform's."  
- **C)** "Because smart contracts are more secure than databases and Web3 is decentralised."  
- **D)** "Blockchain uses cryptography which makes it unhackable, unlike normal databases."  

**Your Answer:** [B]  

**Your Explanation:**  
[2–3 sentences explaining what makes this answer correct. What did you learn about why blockchain matters in Africa?]  
In a normal database, theres an entity responsible for managing that data and is at risk of being manipulated or hacked or just lost. In Blockchain network data is spread accross so its always there and anyone can always see it and cannot be modified.
---

## PART 2: DeFi & NFT Integration (Advanced Concepts)

**Scenario:** A DeFi protocol experiences the following sequence of events:

- A liquidity provider adds 10 ETH and 20,000 USDC to an AMM pool (constant product formula: x × y = k)  
- A trader swaps 2 ETH for USDC (no fees for simplicity)  
- The protocol's governance token holders vote on implementing impermanent loss protection  
- An NFT marketplace integrates with the DEX to enable ERC-1155 token swaps  

---

### Question: Multi-Concept Synthesis

**Which statement correctly combines understanding of AMMs, governance, and technical implementation?**

- **A)** After the 2 ETH swap, the liquidity provider will have exactly the same USD value as before because the constant product formula maintains equal ratios. ERC-1155 tokens cannot be traded on AMMs since they support both fungible and non-fungible characteristics.  
- **B)** The trader will receive approximately 3,333 USDC from the swap (calculated using k = 10 × 20,000 = 200,000, then 12 × y = 200,000). Impermanent loss protection would compensate the LP for price divergence between the pool ratio and external market prices. ERC-1155's batch transfer capability makes it more gas-efficient than ERC-721 for marketplace integration.  
- **C)** The liquidity provider experiences impermanent loss because the pool maintains a constant product rather than constant ratio. ERC-721 would be more suitable than ERC-1155 for the NFT marketplace since individual NFTs require unique transactions.  
- **D)** The constant product formula prevents any impermanent loss by automatically rebalancing. DAOs cannot implement financial protections due to smart contract immutability. ERC-1155 tokens are incompatible with standard DEX protocols.  

**Your Answer:** [B]  

**Your Reasoning:**  

- **AMM Mathematics:** Using the constant product formula (x × y = k), initial state is 10 ETH × 20,000 USDC = 200,000 k. After adding 2 ETH we have 12 ETH so y = 200,000 / 12 = 16,666.67 USDC. The trader receives ~3,333 USDC. The liquidity provider experiences impermanent loss as the pool ratio diverges from external market prices.  
- **DeFi Governance:** Impermanent loss occurs when token prices in the pool change relative to when the liquidity was added. Protection would compensate LPs for this loss. DAOs can implement this through smart contract upgrades or insurance pools.  
- **Token Standards:** ERC-1155 is preferred because it supports both fungible and non-fungible tokens. 

---
## SUBMISSION CHECKLIST

- You answered all questions for **BOTH PART 1 AND PART 2**  
- Your answers include reasoning (not just A/B/C/D)  
- For PART 1 Q2: You showed your gas cost calculations  
- For PART 2: You addressed all three concept areas (AMM, Governance, Token Standards)  
- You committed and pushed to GitLab  

---

**Challenges faced:** [I found the gas cost calculation for Question 2 confusing at first but it clicked once I understood the conversion rate of Ether and gas and gwei. The multi-concept synthesis question required recalling multiple DeFi concepts and combining them coherently, which took some time to structure properly.]  
