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
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
    mapping(address => uint256) public nftHolders;

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
            defaultCharacters.push(CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    attackDamage: characterAttackDamage[i]
                }));

            CharacterAttributes memory c = defaultCharacters[i];
            console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
        }
        _tokenIds.increment();
    }

    function mintCharacterNFT(uint _characterIndex) external {
        uint256 newItemId = _tokenIds.current();

        _safeMint(msg.sender, newItemId);

        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
        
        nftHolders[msg.sender] = newItemId;
        _tokenIds.increment();
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];
    }
}