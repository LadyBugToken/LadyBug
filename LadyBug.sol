// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ILadyBugStaking {
    function stake(uint256 amount) external;
    function unstake() external;
    // Add other functions from LadyBugStaking as needed
}

interface ILadyBugLottery {
    function enterLottery() external;
    function drawWinner() external;
    // Add other functions from LadyBugLottery as needed
}

contract LadyBug is ERC20, ERC20Burnable, ERC20Permit, Ownable {
    uint256 public reflectionFeePercentage;
    uint256 public burnFeePercentage;
    uint256 public sustainabilityFeePercentage;
    address public sustainabilityWallet;

    string[10] public levelNames;
    uint256[10] public levelThresholds;

    ILadyBugStaking private stakingContract;
    ILadyBugLottery private lotteryContract;

    constructor(
        string memory name_,
        string memory symbol_,
        address _sustainabilityWallet
    ) 
    ERC20(name_, symbol_) 
    ERC20Permit(name_) 
    Ownable(msg.sender) // If your Ownable requires an address
    {
        require(_sustainabilityWallet != address(0), "Sustainability wallet is the zero address");
        _mint(msg.sender, 1000000000 * 10 ** decimals());
        sustainabilityWallet = _sustainabilityWallet;

        // Initialize level names and thresholds
        levelNames = [
            "Bronze I", "Bronze II",
            "Silver I", "Silver II",
            "Gold I", "Gold II",
            "Platinum I", "Platinum II",
            "Diamond", "Champion"
        ];
        for (uint8 i = 0; i < 10; i++) {
            levelThresholds[i] = (i + 1) * 1000 * 10 ** decimals();
        }
    }

    // Set the staking contract address
    function setStakingContract(address _stakingAddress) external onlyOwner {
        stakingContract = ILadyBugStaking(_stakingAddress);
    }

    // Set the lottery contract address
    function setLotteryContract(address _lotteryAddress) external onlyOwner {
        lotteryContract = ILadyBugLottery(_lotteryAddress);
    }

    // Enter staking
    function enterStaking(uint256 amount) public {
        stakingContract.stake(amount);
    }

    // Leave staking
    function leaveStaking() public {
        stakingContract.unstake();
    }

    // Enter lottery
    function participateInLottery() public {
        lotteryContract.enterLottery();
    }

    // Conduct lottery draw
    function conductLotteryDraw() public onlyOwner {
        lotteryContract.drawWinner();
    }

    // User level based on their token balance
    function getUserLevel(address user) public view returns (string memory) {
        uint256 userBalance = balanceOf(user);
        for (uint8 i = 0; i < levelThresholds.length; i++) {
            if (userBalance < levelThresholds[i]) {
                return levelNames[i];
            }
        }
        return levelNames[levelNames.length - 1];
    }

    // Additional functions and overrides...
}
