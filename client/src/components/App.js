import React, { Component } from "react";
import StakeToken from "../contracts/StakeToken.json";
import RewardToken from "../contracts/RewardToken.json";
import RewardsFarm from "../contracts/RewardsFarm.json";
import Web3 from "web3";
import "./App.css";
import Navbar from "./Navbar";
import Main from "./Main";

class App extends Component {
  async loadWeb3() {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      await window.ethereum.enable();
    } else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider);
    } else {
      window.alert("No ethereum browser detected. Try installing metamask");
    }
  }

  async loadBlockchainData() {
    const web3 = window.web3;
    const accounts = await web3.eth.getAccounts();
    this.setState({ account: accounts[0] });
    const networkId = await web3.eth.net.getId();
    // console.log(networkId);

    // load StakeToken
    const stakeTokenData = StakeToken.networks[networkId];
    if (stakeTokenData) {
      const stakeToken = new web3.eth.Contract(
        StakeToken.abi,
        stakeTokenData.address
      );
      this.setState({ stakeToken });
      let stakeTokenBal = await stakeToken.methods
        .balanceOf(this.state.account)
        .call();
      this.setState({
        stakeTokenBal: stakeTokenBal.toString(),
      });
    } else {
      window.alert(`StakeToken contract hasn't been deployed`);
    }

    // load DappToken
    const rewardsTokenData = RewardToken.networks[networkId];
    if (rewardsTokenData) {
      const rewardsToken = new web3.eth.Contract(
        RewardToken.abi,
        rewardsTokenData.address
      );
      this.setState({ rewardsToken });
      let rewardsTokenBal = await rewardsToken.methods
        .balanceOf(this.state.account)
        .call();
      this.setState({
        rewardsTokenBal: rewardsTokenBal.toString(),
      });
    } else {
      window.alert(`RewardsToken contract hasn't been deployed`);
    }
    // Load Rewards Farm
    const rewardsFarmData = RewardsFarm.networks[networkId];
    if (rewardsFarmData) {
      const rewardsFarm = new web3.eth.Contract(
        RewardsFarm.abi,
        rewardsFarmData.address
      );
      this.setState({ rewardsFarm });
      let stakingBalance = await rewardsFarm.methods
        .stakingBalance(this.state.account)
        .call();
      this.setState({
        stakingBalance: stakingBalance.toString(),
      });
    } else {
      window.alert(`RewardsFarm contract hasn't been deployed`);
    }

    this.setState({ loading: false });
  }
  stakeTokens(amount) {
    this.setState({ loading: true });
    this.state.stakeToken.methods
      .approve(this.state.rewardsFarm._address, amount)
      .send({ from: this.state.account })
      .on("transactionHash", (hash) => {
        this.state.rewardsFarm.methods
          .stakeTokens(amount)
          .send({ from: this.state.account })
          .on("transactionHash", (hash) => {
            this.setState({ loading: false });
          });
      });
  }
  unstakeTokens = (amount) => {
    this.setState({ loading: true });
    this.state.rewardsFarm.methods
      .unstakeTokens()
      .send({ from: this.state.account })
      .on("transactionHash", (hash) => {
        this.setState({ loading: false });
      });
  };
  async componentWillMount() {
    await this.loadWeb3();
    await this.loadBlockchainData();
  }
  constructor(props) {
    super(props);
    this.state = {
      account: "0x0",
      stakeToken: {},
      rewardsToken: {},
      stakeTokenBal: "0",
      rewardsTokenBal: "0",
      stakingBalance: "0",
      loading: true,
    };
  }
  render() {
    let content;
    if (this.state.loading) {
      content = (
        <p id="loader" className="text-center">
          Loading...
        </p>
      );
    } else {
      content = (
        <Main
          stakeTokenBal={this.state.stakeTokenBal}
          rewardsTokenBal={this.state.rewardsTokenBal}
          stakingBalance={this.state.stakingBalance}
          stakeTokens={this.stakeTokens.bind(this)}
          unstakeTokens={this.unstakeTokens.bind(this)}
        />
      );
    }
    return (
      <div>
        <Navbar account={this.state.account} />
        <div className="container-fluid mt-5">
          <div className="row">
            <main
              role="main"
              className="col-lg-12 mx-auto"
              style={{ maxWidth: "600px" }}
            >
              <div className="content mr-auto ml-auto">
                <a
                  href="https://github.com/Lanrepopson"
                  target="_blank"
                  rel="noopener noreferrer"
                ></a>

                {content}
              </div>
            </main>
          </div>
        </div>
      </div>
    );
  }
}

export default App;
