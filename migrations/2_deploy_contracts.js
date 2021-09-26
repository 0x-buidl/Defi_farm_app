const RewardToken = artifacts.require("RewardToken");
const StakeToken = artifacts.require("StakeToken");
const RewardsFarm = artifacts.require(`RewardsFarm`);
const tokens = (n) => web3.utils.toWei(n, `ether`);
module.exports = async function (_deployer, network, accounts) {
  // Use deployer to state migration tasks.
  await _deployer.deploy(
    RewardToken,
    "Reward Token",
    "RT",
    tokens("10000000"),
    tokens(`4000000`),
    1632744000
  );
  const rewardToken = await RewardToken.deployed();


  await _deployer.deploy(StakeToken);
  const stakeToken = await StakeToken.deployed();

  await _deployer.deploy(
    RewardsFarm,
    rewardToken.address,
    stakeToken.address
  );
  const rewardsFarm = await RewardsFarm.deployed();

  // Transfer all rewards token to the farm
  await rewardToken.transfer(rewardsFarm.address, tokens(`4000000`), {
    from: accounts[0],
  });
  //   Transfer 1000   DAI tokens to investor
  await stakeToken.transfer(accounts[1], tokens(`1000`));
};
