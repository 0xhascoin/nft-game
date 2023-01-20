import React, { useEffect, useState } from 'react';
import twitterLogo from './assets/twitter-logo.svg';
import './App.css';
import { CONTRACT_ADDRESS, transformCharacterData } from './constants';
import myEpicGame from './utils/MyEpicGame.json';
import { ethers } from 'ethers';


import SelectCharacter from './components/selectCharacter';
import Arena from './components/arena';
import LoadingIndicator from './components/loadingIndicator';

// Constants
const TWITTER_HANDLE = '0xHascoin';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;

const App = () => {
  const [currentAccount, setCurrentAccount] = useState(null);
  const [characterNFT, setCharacterNFT] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  const checkNetwork = async () => {
    try {
      if (window.ethereum.networkVersion !== '5') {
        alert("Please connect to Goerli!")
      }
    } catch (error) {
      console.error(error)
    }
  }

  const checkIfWalletIsConnected = async () => {
    try {
      const { ethereum } = window;
      if (!ethereum) {
        console.log("Make sure you have Metamask.");
        setIsLoading(false);
        return;
      } else {
        console.log("We have the ethereum object: ", ethereum);
        const accounts = await ethereum.request({ method: "eth_accounts" });

        if (accounts.length !== 0) {
          const account = accounts[0];
          console.log('Found an authorized account:', account);
          setCurrentAccount(account);
        } else {
          console.log("No authorized account found.")
        }
      }
    } catch (error) {
      console.error(error);
    }
    setIsLoading(false);
  };

  const connectWalletAction = async () => {
    try {
      const { ethereum } = window;
      if (!ethereum) {
        console.log("Make sure you have Metamask.");
        alert("Get Metamask.")
        return;
      } else {
        const accounts = await ethereum.request({ method: "eth_requestAccounts" });
        console.log("Connected: ", accounts[0]);
        setCurrentAccount(accounts[0]);
      }
    } catch (error) {
      console.error(error);
    }
  }

  const renderContent = () => {
    if(isLoading) return <LoadingIndicator />

    if (!currentAccount) {
      return (
        <div className="connect-wallet-container">
          <img
            src="https://uploads-ssl.webflow.com/5fb39592cb1bfc03c9f9b6d2/6324662e5ee3110438933c1b_COBE-Pink-Elephant-Midjourney-Article.jpg"
            alt="Banner"
          />
          <button
            className="cta-button connect-wallet-button"
            onClick={connectWalletAction}
          >
            Connect Wallet To Get Started
          </button>
        </div>
      )
    } else if (currentAccount && !characterNFT) {
      return (
        <SelectCharacter setCharacterNFT={setCharacterNFT} />
      )
    } else if (currentAccount && characterNFT) {
      return (
        <Arena characterNFT={characterNFT} currentAccount={currentAccount} setCharacterNFT={setCharacterNFT} />
      )
    }
  }

  useEffect(() => {
    setIsLoading(true);
    checkIfWalletIsConnected();
  }, []);

  useEffect(() => {
    const fetchNFTMetadata = async () => {
      console.log("Checking for Character NFT on address: ", currentAccount);
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const gameContract = new ethers.Contract(
        CONTRACT_ADDRESS,
        myEpicGame.abi,
        signer
      );

      const txn = await gameContract.checkIfUserHasNFT();
      if(txn.name) {
        console.log("User has Character NFT.");
        setCharacterNFT(transformCharacterData(txn));
      } else {
        console.log("No Character NFT found.");
      }

      setIsLoading(false);
    };

    if(currentAccount) {
      console.log("Current Account: ", currentAccount);
      fetchNFTMetadata();
    }
  }, [currentAccount]);

  

  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header gradient-text">NFT Game</p>
          <p className="sub-text">Team up to protect the Metaverse!</p>
          {renderContent()}
        </div>
        <div className="footer-container">
          <img alt="Twitter Logo" className="twitter-logo" src={twitterLogo} />
          <a
            className="footer-text"
            href={TWITTER_LINK}
            target="_blank"
            rel="noreferrer"
          >{`built with @${TWITTER_HANDLE}`}</a>
        </div>
      </div>
    </div>
  );
};

export default App;