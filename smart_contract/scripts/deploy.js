const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
    const gameContract = await gameContractFactory.deploy(
        ["Winnie The Pooh", "Baby Snorlax", "Yoda"],
        ["https://cdn.midjourney.com/b97753f5-9d3c-4cfa-bc1d-0b83542789fe/grid_0.png",
            "https://cdn.midjourney.com/0be7c023-a889-4c97-9ed1-c9c8b84c075c/grid_0.png",
            "https://cdn.midjourney.com/672cec5f-517e-4e33-be84-22fa92624704/grid_0.png"],
        [100, 200, 300],
        [100, 50, 25],
        "Boss Elmo", // Boss name
        "https://media.discordapp.net/attachments/1005574417348309073/1065464938723819600/Roarian_Muppet_in_the_Adeptus_Mechanicus_6ebca082-2792-4caa-bde3-b5843a8ce6de.png", // Boss image
        10000, // Boss hp
        50 // Boss attack damage
    );
    await gameContract.deployed();
    console.log(`MyEpicGame.sol contract deployed to: ${gameContract.address}`);

    let txn;
    txn = await gameContract.mintCharacterNFT(0);
    await txn.wait();
    console.log("Minted NFT #1");

    txn = await gameContract.mintCharacterNFT(1);
    await txn.wait();
    console.log("Minted NFT #2");

    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();
    console.log("Minted NFT #3");

    txn = await gameContract.mintCharacterNFT(1);
    await txn.wait();
    console.log("Minted NFT #4");

    console.log("Done deploying and minting!");
};

const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();