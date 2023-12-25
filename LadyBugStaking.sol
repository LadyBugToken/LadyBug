// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LadyBug.sol"; // Make sure this import points to the location of your LadyBug token contract

contract LadyBugStaking {
    LadyBug public ladyBugToken;

    struct Stake {
        uint256 amount;
        uint256 since;
    }

    struct RewardTier {
        uint256 timeThreshold;
        uint256 rewardRate;
    }

    RewardTier[] public rewardTiers;

    mapping(address => Stake) public stakes;

    constructor(address _ladyBugToken) {
        ladyBugToken = LadyBug(_ladyBugToken);
        // Initialize reward tiers
        rewardTiers.push(RewardTier(30 days, 2));  // Tier 1: 2% for 1-30 days
        rewardTiers.push(RewardTier(90 days, 4));  // Tier 2: 4% for 31-90 days
        rewardTiers.push(RewardTier(180 days, 6)); // Tier 3: 6% for 91-180 days
        rewardTiers.push(RewardTier(181 days, 10)); // Tier 4: 10% for 181+ days
    }

    function stake(uint256 amount) public {
        require(amount > 0, "Cannot stake 0 tokens");
        require(ladyBugToken.transferFrom(msg.sender, address(this), amount), "Stake failed");
        stakes[msg.sender].amount += amount;
        stakes[msg.sender].since = block.timestamp;
    }

    function unstake() public {
        Stake memory userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No tokens to unstake");

        uint256 reward = calculateReward(msg.sender);
        require(ladyBugToken.transfer(msg.sender, userStake.amount + reward), "Unstake failed");

        delete stakes[msg.sender];
    }

    function calculateReward(address staker) public view returns (uint256) {
        Stake memory userStake = stakes[staker];
        uint256 totalDuration = block.timestamp - userStake.since;
        uint256 rewardRate = getRewardRateForDuration(totalDuration);

        // Assuming rewardRate is annual, and there are 31,536,000 seconds in a year
        uint256 reward = totalDuration * userStake.amount * rewardRate / 31_536_000 / 100;
        return reward;
    }

    function getRewardRateForDuration(uint256 duration) internal view returns (uint256) {
        for (uint256 i = 0; i < rewardTiers.length; i++) {
            if (duration <= rewardTiers[i].timeThreshold) {
                return rewardTiers[i].rewardRate;
            }
        }
        return rewardTiers[rewardTiers.length - 1].rewardRate;
    }

    function getPotentialReward(address staker) public view returns (uint256) {
        return calculateReward(staker);
    }

    // Additional functions such as updating reward tiers, claiming rewards, etc.
}
