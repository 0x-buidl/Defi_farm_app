// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 < 0.9.0;

import './RewardToken.sol';
import './StakeToken.sol';

contract RewardsFarm{
    string public name = 'Dapp Token Farm';
    address public owner;
    RewardToken public rewardsToken;
    StakeToken public stakeToken;
    address[] public stakers;
    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;
    


    constructor (RewardToken _rewardToken, StakeToken _stakeToken)   {
        rewardsToken = _rewardToken;
        stakeToken = _stakeToken;
        owner = msg.sender;
    }

    // 1. Stake Tokens 
    function stakeTokens(uint _amount) public {
        require(_amount > 0, 'Rewards Farm:: Cannot stake 0 tokens');
        // Transfer Staking tokens to this contract
        stakeToken.transferFrom(msg.sender, address(this), _amount);
        // update staking balance
        stakingBalance[msg.sender] += _amount; 
        // Add user to stakers array *only* if they havent staked before
        if(!hasStaked[msg.sender]){
        stakers.push(msg.sender);
        }   
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    // 2. Unstaking tokens 
    function unstakeTokens() public {
        uint balance = stakingBalance[msg.sender];
        require( balance > 0, 'Rewards Farm:: There is no staking balance left.');
        // Transfer staketokens tokens
        stakeToken.transfer(msg.sender, balance);

        // Reset staking balance
        stakingBalance[msg.sender] = 0;

        // update staking status 
        isStaking[msg.sender] = false;
        

    }

    // 3. Issuing tokens
    function issueTokens() public {
        require(msg.sender == owner, 'Rewards Farm:: Only authorized address can call this.');
        for (uint i = 0; i < stakers.length; i++) {
           address recipient = stakers[i];
           uint balance = stakingBalance[recipient];
        //    reward 75% of their staked amount
           if (balance > 0) rewardsToken.transfer(recipient, balance * 75/100  );
        }
    }
}