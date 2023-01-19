const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
      ["Winnie The Pooh", "Baby Snorlax", "Yoda"],
      ["https://cdn.midjourney.com/b97753f5-9d3c-4cfa-bc1d-0b83542789fe/grid_0.png",
          "https://cdn.midjourney.com/0be7c023-a889-4c97-9ed1-c9c8b84c075c/grid_0.png",
          "https://cdn.midjourney.com/672cec5f-517e-4e33-be84-22fa92624704/grid_0.png"],
      [100, 200, 300],
      [100, 50, 25],
      "Elmo", // Boss name
      "https://preview.redd.it/elmo-for-those-having-one-of-those-days-something-fun-v0-1ze9x2avki4a1.png?auto=webp&s=ed15be8ad7f6509fbd245c057283cd77114fd23b", // Boss image
      500, // Boss hp
      50 // Boss attack damage
  );
  await gameContract.deployed();
  console.log(`MyEpicGame.sol contract deployed to: ${gameContract.address}`);
  
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