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

    struct BigBoss {
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    BigBoss public bigBoss;

    uint randNonce = 0;

    // This is an array of CharacterAttributes structs
    // which hold the default characters' attributes.
    CharacterAttributes[] defaultCharacters;

    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(address sender, uint newBossHp, uint newPlayerHp);

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDamage,
        string memory bossName,
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDamage
    ) ERC721("AI Heros", "AIH") {
        console.log("MyEpicGame.sol constructor()");

        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });

        console.log(
            "Done initializing boss %s w/ HP %s, img %s",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.imageURI
        );

        for (uint i = 0; i < characterNames.length; i++) {
            // create a new instance of CharacterAttributes
            // for each character submitted into the constructor.
            // and store it in the defaultCharacters array
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    attackDamage: characterAttackDamage[i]
                })
            );

            // assign the current character attributes to memory variable c
            CharacterAttributes memory c = defaultCharacters[i];
            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
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

        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            newItemId,
            _characterIndex
        );

        // This line assigns the token ID, newItemId, to the msg.sender address in the nftHolders mapping.
        nftHolders[msg.sender] = newItemId;
        _tokenIds.increment();
        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(
            charAttributes.attackDamage
        );

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                charAttributes.name,
                " -- NFT #: ",
                Strings.toString(_tokenId),
                '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
                charAttributes.imageURI,
                '", "attributes": [ { "trait_type": "Health Points", "value": ',
                strHp,
                ', "max_value":',
                strMaxHp,
                '}, { "trait_type": "Attack Damage", "value": ',
                strAttackDamage,
                "} ]}"
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function attackBoss() public {
        // Get the state of the player's NFT.
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];
        console.log(
            "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
            player.name,
            player.hp,
            player.attackDamage
        );
        console.log(
            "Boss %s has %s HP and %s AD",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.attackDamage
        );

        // Make sure the player has more than 0 HP.
        require(player.hp > 0, "Your NFTs is out of HP");

        // Make sure the boss has more than 0 HP.
        require(bigBoss.hp > 0, "The boss is out of HP");

        console.log("%s swings at %s...", player.name, bigBoss.name);

        // Allow player to attack boss.
        if (bigBoss.hp < player.attackDamage) {
            bigBoss.hp = 0;
            console.log("The boss is dead!");
        } else {
            bigBoss.hp = bigBoss.hp - player.attackDamage;
        }

        // Allow boss to attack player.
        if (player.hp < bigBoss.attackDamage) {
            player.hp = 0;
            console.log("Your player is dead!");
        } else {
            if (randomInt(10) > 5) {
                player.hp = player.hp - bigBoss.attackDamage;
                console.log(
                    "%s attacked player. New player hp: %s",
                    bigBoss.name,
                    player.hp
                );
            } else {
                console.log("%s missed!\n", bigBoss.name);
            }
        }

        console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
        console.log("Boss attacked player. New player hp: %s\n", player.hp);
        emit AttackComplete(msg.sender, bigBoss.hp, player.hp);

    }

    function randomInt(uint _modulus) internal returns (uint) {
        randNonce++; // increase nonce
        return
            uint(
                keccak256(
                    abi.encodePacked(
                        block.timestamp, // an alias for 'block.timestamp'
                        msg.sender, // your address
                        randNonce
                    )
                )
            ) % _modulus; // modulo using the _modulus argument
    }

    function checkIfUserHasNFT()
        public
        view
        returns (CharacterAttributes memory)
    {
        // Get the tokenId of the user's character NFT
        uint256 userNftTokenId = nftHolders[msg.sender];

        // If the user has a tokenId in the map, return their character.
                // Else, return an empty character.

        if(userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        } else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
        return defaultCharacters;
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }
}
