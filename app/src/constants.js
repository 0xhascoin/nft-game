const CONTRACT_ADDRESS = '0x5Ad5B51Ce64c651D4b95CcEb4a7BeaD1aa0c33Ed';

const transformCharacterData = (characterData) => {
    return {
        name: characterData.name,
        imageURI: characterData.imageURI,
        hp: characterData.hp.toNumber(),
        maxHp: characterData.maxHp.toNumber(),
        attackDamage: characterData.attackDamage.toNumber(),
    }
}

export { CONTRACT_ADDRESS, transformCharacterData };