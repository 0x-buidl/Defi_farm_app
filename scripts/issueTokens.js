const RewardsFarm = artifacts.require(`RewardsFarm`);

module.exports = async function (callback) {
  let rewardsFarm = await RewardsFarm.deployed();
  await rewardsFarm.issueTokens();

  console.log("Token is issued");
};
