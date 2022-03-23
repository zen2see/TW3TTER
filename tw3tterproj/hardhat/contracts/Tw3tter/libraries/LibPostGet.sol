// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {LibAppStorage, PostGetCollateralTypeInfo, AppStorage, PostGet, ItemType, NUMERIC_TRAITS_NUM, EQUIPPED_WEARABLE_SLOTS, PORTAL_POSTGETS_NUM} from "./LibAppStorage.sol";
import {LibERC20} from "../../shared/libraries/LibERC20.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {LibERC721} from "../../shared/libraries/LibERC721.sol";
import {LibItems, ItemTypeIO} from "../libraries/LibItems.sol";

struct PostGetCollateralTypeIO {
    address collateralType;
    PostGetCollateralTypeInfo collateralTypeInfo;
}

struct PostGetInfo {
    uint256 tokenId;
    string name;
    address owner;
    uint256 randomNumber;
    uint256 status;
    int16[NUMERIC_TRAITS_NUM] numericTraits;
    int16[NUMERIC_TRAITS_NUM] modifiedNumericTraits;
    uint16[EQUIPPED_WEARABLE_SLOTS] equippedWearables;
    address collateral;
    address escrow;
    uint256 stakedAmount;
    uint256 minimumStake;
    uint256 kinship; //The kinship value of this PostGet. Default is 50.
    uint256 lastInteracted;
    uint256 experience; //How much XP this PostGet has accrued. Begins at 0.
    uint256 toNextLevel;
    uint256 usedSkillPoints; //number of skill points used
    uint256 level; //the current postget level
    uint256 hauntId;
    uint256 baseRarityScore;
    uint256 modifiedRarityScore;
    bool locked;
    ItemTypeIO[] items;
}

struct PortalPostGetTraitsIO {
    uint256 randomNumber;
    int16[NUMERIC_TRAITS_NUM] numericTraits;
    address collateralType;
    uint256 minimumStake;
}

struct InternalPortalPostGetTraitsIO {
    uint256 randomNumber;
    int16[NUMERIC_TRAITS_NUM] numericTraits;
    address collateralType;
    uint256 minimumStake;
}

library LibPostGet {
    uint8 constant STATUS_CLOSED_PORTAL = 0;
    uint8 constant STATUS_VRF_PENDING = 1;
    uint8 constant STATUS_OPEN_PORTAL = 2;
    uint8 constant STATUS_POSTGET = 3;

    event PostGetInteract(uint256 indexed _tokenId, uint256 kinship);

    function toNumericTraits(
        uint256 _randomNumber,
        int16[NUMERIC_TRAITS_NUM] memory _modifiers,
        uint256 _hauntId
    ) internal pure returns (int16[NUMERIC_TRAITS_NUM] memory numericTraits_) {
        if (_hauntId == 1) {
            for (uint256 i; i < NUMERIC_TRAITS_NUM; i++) {
                uint256 value = uint8(uint256(_randomNumber >> (i * 8)));
                if (value > 99) {
                    value /= 2;
                    if (value > 99) {
                        value = uint256(keccak256(abi.encodePacked(_randomNumber, i))) % 100;
                    }
                }
                numericTraits_[i] = int16(int256(value)) + _modifiers[i];
            }
        } else {
            for (uint256 i; i < NUMERIC_TRAITS_NUM; i++) {
                uint256 value = uint8(uint256(_randomNumber >> (i * 8)));
                if (value > 99) {
                    value = value - 100;
                    if (value > 99) {
                        value = uint256(keccak256(abi.encodePacked(_randomNumber, i))) % 100;
                    }
                }
                numericTraits_[i] = int16(int256(value)) + _modifiers[i];
            }
        }
    }

    function rarityMultiplier(int16[NUMERIC_TRAITS_NUM] memory _numericTraits) internal pure returns (uint256 multiplier) {
        uint256 rarityScore = LibPostGet.baseRarityScore(_numericTraits);
        if (rarityScore < 300) return 10;
        else if (rarityScore >= 300 && rarityScore < 450) return 10;
        else if (rarityScore >= 450 && rarityScore <= 525) return 25;
        else if (rarityScore >= 526 && rarityScore <= 580) return 100;
        else if (rarityScore >= 581) return 1000;
    }

    function singlePortalPostGetTraits(
        uint256 _hauntId,
        uint256 _randomNumber,
        uint256 _option
    ) internal view returns (InternalPortalPostGetTraitsIO memory singlePortalPostGetTraits_) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 randomNumberN = uint256(keccak256(abi.encodePacked(_randomNumber, _option)));
        singlePortalPostGetTraits_.randomNumber = randomNumberN;

        address collateralType = s.hauntCollateralTypes[_hauntId][randomNumberN % s.hauntCollateralTypes[_hauntId].length];
        singlePortalPostGetTraits_.numericTraits = toNumericTraits(randomNumberN, s.collateralTypeInfo[collateralType].modifiers, _hauntId);
        singlePortalPostGetTraits_.collateralType = collateralType;

        PostGetCollateralTypeInfo memory collateralInfo = s.collateralTypeInfo[collateralType];
        uint256 conversionRate = collateralInfo.conversionRate;

        //Get rarity multiplier
        uint256 multiplier = rarityMultiplier(singlePortalPostGetTraits_.numericTraits);

        //First we get the base price of our collateral in terms of DAI
        uint256 collateralDAIPrice = ((10**IERC20(collateralType).decimals()) / conversionRate);

        //Then multiply by the rarity multiplier
        singlePortalPostGetTraits_.minimumStake = collateralDAIPrice * multiplier;
    }

    function portalPostGetTraits(uint256 _tokenId)
        internal
        view
        returns (PortalPostGetTraitsIO[PORTAL_POSTGETS_NUM] memory portalPostGetTraits_)
    {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(s.postgets[_tokenId].status == LibPostGet.STATUS_OPEN_PORTAL, "PostGetFacet: Portal not open");

        uint256 randomNumber = s.tokenIdToRandomNumber[_tokenId];

        uint256 hauntId = s.postgets[_tokenId].hauntId;

        for (uint256 i; i < portalPostGetTraits_.length; i++) {
            InternalPortalPostGetTraitsIO memory single = singlePortalPostGetTraits(hauntId, randomNumber, i);
            portalPostGetTraits_[i].randomNumber = single.randomNumber;
            portalPostGetTraits_[i].collateralType = single.collateralType;
            portalPostGetTraits_[i].minimumStake = single.minimumStake;
            portalPostGetTraits_[i].numericTraits = single.numericTraits;
        }
    }

    function getPostGet(uint256 _tokenId) internal view returns (PostGetInfo memory postgetInfo_) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        postgetInfo_.tokenId = _tokenId;
        postgetInfo_.owner = s.postgets[_tokenId].owner;
        postgetInfo_.randomNumber = s.postgets[_tokenId].randomNumber;
        postgetInfo_.status = s.postgets[_tokenId].status;
        postgetInfo_.hauntId = s.postgets[_tokenId].hauntId;
        if (postgetInfo_.status == STATUS_POSTGET) {
            postgetInfo_.name = s.postgets[_tokenId].name;
            postgetInfo_.equippedWearables = s.postgets[_tokenId].equippedWearables;
            postgetInfo_.collateral = s.postgets[_tokenId].collateralType;
            postgetInfo_.escrow = s.postgets[_tokenId].escrow;
            postgetInfo_.stakedAmount = IERC20(postgetInfo_.collateral).balanceOf(postgetInfo_.escrow);
            postgetInfo_.minimumStake = s.postgets[_tokenId].minimumStake;
            postgetInfo_.kinship = kinship(_tokenId);
            postgetInfo_.lastInteracted = s.postgets[_tokenId].lastInteracted;
            postgetInfo_.experience = s.postgets[_tokenId].experience;
            postgetInfo_.toNextLevel = xpUntilNextLevel(s.postgets[_tokenId].experience);
            postgetInfo_.level = postgetLevel(s.postgets[_tokenId].experience);
            postgetInfo_.usedSkillPoints = s.postgets[_tokenId].usedSkillPoints;
            postgetInfo_.numericTraits = s.postgets[_tokenId].numericTraits;
            postgetInfo_.baseRarityScore = baseRarityScore(postgetInfo_.numericTraits);
            (postgetInfo_.modifiedNumericTraits, postgetInfo_.modifiedRarityScore) = modifiedTraitsAndRarityScore(_tokenId);
            postgetInfo_.locked = s.postgets[_tokenId].locked;
            postgetInfo_.items = LibItems.itemBalancesOfTokenWithTypes(address(this), _tokenId);
        }
    }

    //Only valid for claimed PostGets
    function modifiedTraitsAndRarityScore(uint256 _tokenId)
        internal
        view
        returns (int16[NUMERIC_TRAITS_NUM] memory numericTraits_, uint256 rarityScore_)
    {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(s.postgets[_tokenId].status == STATUS_POSTGET, "PostGetFacet: Must be claimed");
        PostGet storage postget = s.postgets[_tokenId];
        numericTraits_ = getNumericTraits(_tokenId);
        uint256 wearableBonus;
        for (uint256 slot; slot < EQUIPPED_WEARABLE_SLOTS; slot++) {
            uint256 wearableId = postget.equippedWearables[slot];
            if (wearableId == 0) {
                continue;
            }
            ItemType storage itemType = s.itemTypes[wearableId];
            //Add on trait modifiers
            for (uint256 j; j < NUMERIC_TRAITS_NUM; j++) {
                numericTraits_[j] += itemType.traitModifiers[j];
            }
            wearableBonus += itemType.rarityScoreModifier;
        }
        uint256 baseRarity = baseRarityScore(numericTraits_);
        rarityScore_ = baseRarity + wearableBonus;
    }

    function getNumericTraits(uint256 _tokenId) internal view returns (int16[NUMERIC_TRAITS_NUM] memory numericTraits_) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        //Check if trait boosts from consumables are still valid
        int256 boostDecay = int256((block.timestamp - s.postgets[_tokenId].lastTemporaryBoost) / 24 hours);
        for (uint256 i; i < NUMERIC_TRAITS_NUM; i++) {
            int256 number = s.postgets[_tokenId].numericTraits[i];
            int256 boost = s.postgets[_tokenId].temporaryTraitBoosts[i];

            if (boost > 0 && boost > boostDecay) {
                number += boost - boostDecay;
            } else if ((boost * -1) > boostDecay) {
                number += boost + boostDecay;
            }
            numericTraits_[i] = int16(number);
        }
    }

    function kinship(uint256 _tokenId) internal view returns (uint256 score_) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        PostGet storage postget = s.postgets[_tokenId];
        uint256 lastInteracted = postget.lastInteracted;
        uint256 interactionCount = postget.interactionCount;
        uint256 interval = block.timestamp - lastInteracted;

        uint256 daysSinceInteraction = interval / 24 hours;

        if (interactionCount > daysSinceInteraction) {
            score_ = interactionCount - daysSinceInteraction;
        }
    }

    function xpUntilNextLevel(uint256 _experience) internal pure returns (uint256 requiredXp_) {
        uint256 currentLevel = postgetLevel(_experience);
        requiredXp_ = ((currentLevel**2) * 50) - _experience;
    }

    function postgetLevel(uint256 _experience) internal pure returns (uint256 level_) {
        if (_experience > 490050) {
            return 99;
        }

        level_ = (sqrt(2 * _experience) / 10);
        return level_ + 1;
    }

    function interact(uint256 _tokenId) internal returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 lastInteracted = s.postgets[_tokenId].lastInteracted;
        // if interacted less than 12 hours ago
        if (block.timestamp < lastInteracted + 12 hours) {
            return false;
        }

        uint256 interactionCount = s.postgets[_tokenId].interactionCount;
        uint256 interval = block.timestamp - lastInteracted;
        uint256 daysSinceInteraction = interval / 1 days;
        uint256 l_kinship;
        if (interactionCount > daysSinceInteraction) {
            l_kinship = interactionCount - daysSinceInteraction;
        }

        uint256 hateBonus;

        if (l_kinship < 40) {
            hateBonus = 2;
        }
        l_kinship += 1 + hateBonus;
        s.postgets[_tokenId].interactionCount = l_kinship;

        s.postgets[_tokenId].lastInteracted = uint40(block.timestamp);
        emit PostGetInteract(_tokenId, l_kinship);
        return true;
    }

    //Calculates the base rarity score, including collateral modifier
    function baseRarityScore(int16[NUMERIC_TRAITS_NUM] memory _numericTraits) internal pure returns (uint256 _rarityScore) {
        for (uint256 i; i < NUMERIC_TRAITS_NUM; i++) {
            int256 number = _numericTraits[i];
            if (number >= 50) {
                _rarityScore += uint256(number) + 1;
            } else {
                _rarityScore += uint256(int256(100) - number);
            }
        }
    }

    // Need to ensure there is no overflow of _pogt
    function purchase(address _from, uint256 _pogt) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        //33% to burn address
        uint256 burnShare = (_pogt * 33) / 100;

        //17% to Artists wallet
        uint256 companyShare = (_pogt * 17) / 100;

        //40% to rarity farming rewards
        uint256 rarityFarmShare = (_pogt * 2) / 5;

        //10% to DAO
        uint256 daoShare = (_pogt - burnShare - companyShare - rarityFarmShare);

        // Using 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF as burn address.
        // POGT token contract does not allow transferring to address(0) address: https://etherscan.io/address/0x3F382DbD960E3a9bbCeaE22651E88158d2791550#code
        address pogtContract = s.pogtContract;
        LibERC20.transferFrom(pogtContract, _from, address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF), burnShare);
        LibERC20.transferFrom(pogtContract, _from, s.artists, companyShare);
        LibERC20.transferFrom(pogtContract, _from, s.rarityFarming, rarityFarmShare);
        LibERC20.transferFrom(pogtContract, _from, s.dao, daoShare);
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function validateAndLowerName(string memory _name) internal pure returns (string memory) {
        bytes memory name = abi.encodePacked(_name);
        uint256 len = name.length;
        require(len != 0, "LibPostGet: name can't be 0 chars");
        require(len < 26, "LibPostGet: name can't be greater than 25 characters");
        uint256 char = uint256(uint8(name[0]));
        require(char != 32, "LibPostGet: first char of name can't be a space");
        char = uint256(uint8(name[len - 1]));
        require(char != 32, "LibPostGet: last char of name can't be a space");
        for (uint256 i; i < len; i++) {
            char = uint256(uint8(name[i]));
            require(char > 31 && char < 127, "LibPostGet: invalid character in PostGet name.");
            if (char < 91 && char > 64) {
                name[i] = bytes1(uint8(char + 32));
            }
        }
        return string(name);
    }

    // function addTokenToUser(address _to, uint256 _tokenId) internal {}

    // function removeTokenFromUser(address _from, uint256 _tokenId) internal {}

    function transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        // remove
        uint256 index = s.ownerTokenIdIndexes[_from][_tokenId];
        uint256 lastIndex = s.ownerTokenIds[_from].length - 1;
        if (index != lastIndex) {
            uint32 lastTokenId = s.ownerTokenIds[_from][lastIndex];
            s.ownerTokenIds[_from][index] = lastTokenId;
            s.ownerTokenIdIndexes[_from][lastTokenId] = index;
        }
        s.ownerTokenIds[_from].pop();
        delete s.ownerTokenIdIndexes[_from][_tokenId];
        if (s.approved[_tokenId] != address(0)) {
            delete s.approved[_tokenId];
            emit LibERC721.Approval(_from, address(0), _tokenId);
        }
        // add
        s.postgets[_tokenId].owner = _to;
        s.ownerTokenIdIndexes[_to][_tokenId] = s.ownerTokenIds[_to].length;
        s.ownerTokenIds[_to].push(uint32(_tokenId));
        emit LibERC721.Transfer(_from, _to, _tokenId);
    }
}