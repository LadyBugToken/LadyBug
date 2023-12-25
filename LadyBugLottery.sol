// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LadyBug.sol";

contract LadyBugLottery {
    LadyBug public ladyBugToken;
    address public owner;
    uint256 public lotteryEndTime;
    uint256 public ticketPrice;
    address[] public participants;

    event LotteryEnter(address indexed participant);
    event LotteryWinner(address indexed winner);

    constructor(address _ladyBugToken, uint256 _ticketPrice, uint256 _duration) {
        ladyBugToken = LadyBug(_ladyBugToken);
        owner = msg.sender;
        ticketPrice = _ticketPrice; // Set the ticket price
        lotteryEndTime = block.timestamp + _duration; // Set the lottery duration
    }

    function enterLottery() public {
        require(block.timestamp < lotteryEndTime, "Lottery has ended");
        require(ladyBugToken.transferFrom(msg.sender, address(this), ticketPrice), "Ticket purchase failed");
        
        participants.push(msg.sender);
        emit LotteryEnter(msg.sender);
    }

    function drawWinner() public {
    require(msg.sender == owner, "Only owner can draw winner");
    require(block.timestamp >= lotteryEndTime, "Lottery is still active");
    require(participants.length > 0, "No participants in lottery");

    uint256 winnerIndex = random() % participants.length;
    address winner = participants[winnerIndex];

    // Entire balance of the contract is used as the prize
    uint256 prize = ladyBugToken.balanceOf(address(this));
    require(ladyBugToken.transfer(winner, prize), "Prize transfer failed");

    emit LotteryWinner(winner);

    // Reset the lottery for the next round
    delete participants;
    lotteryEndTime = block.timestamp + 1 weeks; // Reset the lottery for another week
    }


    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants)));
    }
}
