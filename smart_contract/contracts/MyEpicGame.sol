// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";
import "./libraries/Base64.sol";

contract MyEpicGame is ERC721 {

    // struct called CharacterAttributes, 
    // which is used to store information about a character such as its name, image URI, hit points, and attack damage.
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    // This is using statement that makes the Counter type from the Counters library available in the contract 
    // without having to specify the library name.
    using Counters for Counters.Counter;
    
    // this is a private variable of the contract, 
    // which uses the Counter type from the Counters library to generate unique token IDs.
    Counters.Counter private _tokenIds;

    // This is a mapping which maps a token ID to its corresponding CharacterAttributes struct, 
    // it's public so can be accessed by anyone.
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
    
    // This is a mapping which maps an address to its corresponding token ID, 
    // it's public so can be accessed by anyone.
    mapping(address => uint256) public nftHolders;

    // This is an array of CharacterAttributes structs 
    // which hold the default characters' attributes.
    CharacterAttributes[] defaultCharacters;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDamage

    ) 
    ERC721("AI Heros", "AIH")
    {
        console.log("MyEpicGame.sol constructor()");
        for(uint i = 0; i < characterNames.length; i++) {
        
            // create a new instance of CharacterAttributes 
            // for each character submitted into the constructor.
            // and store it in the defaultCharacters array
            defaultCharacters.push(CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    attackDamage: characterAttackDamage[i]
                }));

            // assign the current character attributes to memory variable c
            CharacterAttributes memory c = defaultCharacters[i];
            console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
        }
        // This increments the _tokenIds variable, which is used to generate unique token IDs.
        _tokenIds.increment();
    }

    // This is a function that allows the contract owner 
    // to mint new NFTs with the specified character index, assigning them to the msg.sender
    function mintCharacterNFT(uint _characterIndex) external {
    
        // This line assigns the current value of the _tokenIds counter to newItemId variable.
        uint256 newItemId = _tokenIds.current();

        // This function is inherited from the ERC721 contract and mints a new token to 
        // the msg.sender address with the token ID of newItemId.
        _safeMint(msg.sender, newItemId);

        // This line assigns the CharacterAttributes struct to the newItemId key 
        // in the nftHolderAttributes mapping, with the attributes of the 
        // character that has the _characterIndex.
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
        
        // This line assigns the token ID, newItemId, to the msg.sender address in the nftHolders mapping.
        nftHolders[msg.sender] = newItemId;
        _tokenIds.increment();
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];
    }
}
