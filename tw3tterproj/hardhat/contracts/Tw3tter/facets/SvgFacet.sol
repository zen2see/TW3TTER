// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import {AppStorage, SvgLayer, Dimensions} from "../libraries/LibAppStorage.sol";
import {LibPostGet, PortalPostGetTraitsIO, EQUIPPED_WEARABLE_SLOTS, PORTAL_POSTGETS_NUM, NUMERIC_TRAITS_NUM} from "../libraries/LibPostGet.sol";
import {LibItems} from "../libraries/LibItems.sol";
import {Modifiers, ItemType} from "../libraries/LibAppStorage.sol";
import {LibSvg} from "../libraries/LibSvg.sol";
import {LibStrings} from "../../shared/libraries/LibStrings.sol";

contract SvgFacet is Modifiers {
    /***********************************|
   |             Read Functions         |
   |__________________________________*/

    ///@notice Given an postget token id, return the combined SVG of its layers and its wearables
    ///@param _tokenId the identifier of the token to query
    ///@return ag_ The final svg which contains the combined SVG of its layers and its wearables
    function getPostGetSvg(uint256 _tokenId) public view returns (string memory ag_) {
        require(s.postgets[_tokenId].owner != address(0), "SvgFacet: _tokenId does not exist");

        bytes memory svg;
        uint8 status = s.postgets[_tokenId].status;
        uint256 hauntId = s.postgets[_tokenId].hauntId;
        if (status == LibPostGet.STATUS_CLOSED_PORTAL) {
            // sealed closed portal
            svg = LibSvg.getSvg("portal-closed", hauntId);
        } else if (status == LibPostGet.STATUS_OPEN_PORTAL) {
            // open portal
            svg = LibSvg.getSvg("portal-open", hauntId);
        } else if (status == LibPostGet.STATUS_POSTGET) {
            address collateralType = s.postgets[_tokenId].collateralType;
            svg = getPostGetSvgLayers(collateralType, s.postgets[_tokenId].numericTraits, _tokenId, hauntId);
        }
        ag_ = string(abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">', svg, "</svg>"));
    }

    struct SvgLayerDetails {
        string primaryColor;
        string secondaryColor;
        string cheekColor;
        bytes collateral;
        int256 trait;
        int256[18] eyeShapeTraitRange;
        bytes eyeShape;
        string eyeColor;
        int256[8] eyeColorTraitRanges;
        string[7] eyeColors;
    }

    function getPostGetSvgLayers(
        address _collateralType,
        int16[NUMERIC_TRAITS_NUM] memory _numericTraits,
        uint256 _tokenId,
        uint256 _hauntId
    ) internal view returns (bytes memory svg_) {
        SvgLayerDetails memory details;
        details.primaryColor = LibSvg.bytes3ToColorString(s.collateralTypeInfo[_collateralType].primaryColor);
        details.secondaryColor = LibSvg.bytes3ToColorString(s.collateralTypeInfo[_collateralType].secondaryColor);
        details.cheekColor = LibSvg.bytes3ToColorString(s.collateralTypeInfo[_collateralType].cheekColor);

        // postget body
        svg_ = LibSvg.getSvg("postget", LibSvg.POSTGET_BODY_SVG_ID);
        details.collateral = LibSvg.getSvg("collaterals", s.collateralTypeInfo[_collateralType].svgId);

        bytes32 eyeSvgType = "eyeShapes";
        if (_hauntId != 1) {
            //Convert Haunt into string to match the uploaded category name
            bytes memory haunt = abi.encodePacked(LibSvg.uint2str(_hauntId));
            eyeSvgType = LibSvg.bytesToBytes32(abi.encodePacked("eyeShapesH"), haunt);
        }

        details.trait = _numericTraits[4];

        if (details.trait < 0) {
            details.eyeShape = LibSvg.getSvg(eyeSvgType, 0);
        } else if (details.trait > 97) {
            details.eyeShape = LibSvg.getSvg(eyeSvgType, s.collateralTypeInfo[_collateralType].eyeShapeSvgId);
        } else {
            details.eyeShapeTraitRange = [int256(0), 1, 2, 5, 7, 10, 15, 20, 25, 42, 58, 75, 80, 85, 90, 93, 95, 98];
            for (uint256 i; i < details.eyeShapeTraitRange.length - 1; i++) {
                if (details.trait >= details.eyeShapeTraitRange[i] && details.trait < details.eyeShapeTraitRange[i + 1]) {
                    details.eyeShape = LibSvg.getSvg(eyeSvgType, i);
                    break;
                }
            }
        }

        details.trait = _numericTraits[5];
        details.eyeColorTraitRanges = [int256(0), 2, 10, 25, 75, 90, 98, 100];
        details.eyeColors = [
            "FF00FF", // mythical_low
            "0064FF", // rare_low
            "5D24BF", // uncommon_low
            details.primaryColor, // common
            "36818E", // uncommon_high
            "EA8C27", // rare_high
            "51FFA8" // mythical_high
        ];
        if (details.trait < 0) {
            details.eyeColor = "FF00FF";
        } else if (details.trait > 99) {
            details.eyeColor = "51FFA8";
        } else {
            for (uint256 i; i < details.eyeColorTraitRanges.length - 1; i++) {
                if (details.trait >= details.eyeColorTraitRanges[i] && details.trait < details.eyeColorTraitRanges[i + 1]) {
                    details.eyeColor = details.eyeColors[i];
                    break;
                }
            }
        }

        //Load in all the equipped wearables
        uint16[EQUIPPED_WEARABLE_SLOTS] memory equippedWearables = s.postgets[_tokenId].equippedWearables;

        //Token ID is uint256 max: used for Portal PostGets to close hands
        if (_tokenId == type(uint256).max) {
            svg_ = abi.encodePacked(
                applyStyles(details, _tokenId, equippedWearables),
                LibSvg.getSvg("postget", LibSvg.BACKGROUND_SVG_ID),
                svg_,
                details.collateral,
                details.eyeShape
            );
        }
        //Token ID is uint256 max - 1: used for Gotchi previews to open hands
        else if (_tokenId == type(uint256).max - 1) {
            equippedWearables[0] = 1;
            svg_ = abi.encodePacked(
                applyStyles(details, _tokenId, equippedWearables),
                LibSvg.getSvg("postget", LibSvg.BACKGROUND_SVG_ID),
                svg_,
                details.collateral,
                details.eyeShape
            );

            //Normal token ID
        } else {
            svg_ = abi.encodePacked(applyStyles(details, _tokenId, equippedWearables), svg_, details.collateral, details.eyeShape);
            svg_ = addBodyAndWearableSvgLayers(svg_, equippedWearables);
        }
    }

    //Apply styles based on the traits and wearables
    function applyStyles(
        SvgLayerDetails memory _details,
        uint256 _tokenId,
        uint16[EQUIPPED_WEARABLE_SLOTS] memory equippedWearables
    ) internal pure returns (bytes memory) {
        if (
            _tokenId != type(uint256).max &&
            (equippedWearables[LibItems.WEARABLE_SLOT_BODY] != 0 ||
                equippedWearables[LibItems.WEARABLE_SLOT_HAND_LEFT] != 0 ||
                equippedWearables[LibItems.WEARABLE_SLOT_HAND_RIGHT] != 0)
        ) {
            //Open-hands postget
            return
                abi.encodePacked(
                    "<style>.gotchi-primary{fill:#",
                    _details.primaryColor,
                    ";}.gotchi-secondary{fill:#",
                    _details.secondaryColor,
                    ";}.gotchi-cheek{fill:#",
                    _details.cheekColor,
                    ";}.gotchi-eyeColor{fill:#",
                    _details.eyeColor,
                    ";}.gotchi-primary-mouth{fill:#",
                    _details.primaryColor,
                    ";}.gotchi-sleeves-up{display:none;}",
                    ".gotchi-handsUp{display:none;}",
                    ".gotchi-handsDownOpen{display:block;}",
                    ".gotchi-handsDownClosed{display:none;}",
                    "</style>"
                );
        } else {
            //Normal PostGet, closed hands
            return
                abi.encodePacked(
                    "<style>.gotchi-primary{fill:#",
                    _details.primaryColor,
                    ";}.gotchi-secondary{fill:#",
                    _details.secondaryColor,
                    ";}.gotchi-cheek{fill:#",
                    _details.cheekColor,
                    ";}.gotchi-eyeColor{fill:#",
                    _details.eyeColor,
                    ";}.gotchi-primary-mouth{fill:#",
                    _details.primaryColor,
                    ";}.gotchi-sleeves-up{display:none;}",
                    ".gotchi-handsUp{display:none;}",
                    ".gotchi-handsDownOpen{display:none;}",
                    ".gotchi-handsDownClosed{display:block}",
                    "</style>"
                );
        }
    }

    function getWearableClass(uint256 _slotPosition) internal pure returns (string memory className_) {
        //Wearables

        if (_slotPosition == LibItems.WEARABLE_SLOT_BODY) className_ = "wearable-body";
        if (_slotPosition == LibItems.WEARABLE_SLOT_FACE) className_ = "wearable-face";
        if (_slotPosition == LibItems.WEARABLE_SLOT_EYES) className_ = "wearable-eyes";
        if (_slotPosition == LibItems.WEARABLE_SLOT_HEAD) className_ = "wearable-head";
        if (_slotPosition == LibItems.WEARABLE_SLOT_HAND_LEFT) className_ = "wearable-hand wearable-hand-left";
        if (_slotPosition == LibItems.WEARABLE_SLOT_HAND_RIGHT) className_ = "wearable-hand wearable-hand-right";
        if (_slotPosition == LibItems.WEARABLE_SLOT_PET) className_ = "wearable-pet";
        if (_slotPosition == LibItems.WEARABLE_SLOT_BG) className_ = "wearable-bg";
    }

    function getBodyWearable(uint256 _wearableId) internal view returns (bytes memory bodyWearable_, bytes memory sleeves_) {
        ItemType storage wearableType = s.itemTypes[_wearableId];
        Dimensions memory dimensions = wearableType.dimensions;

        bodyWearable_ = abi.encodePacked(
            '<g class="gotchi-wearable wearable-body',
            // x
            LibStrings.strWithUint('"><svg x="', dimensions.x),
            // y
            LibStrings.strWithUint('" y="', dimensions.y),
            '">',
            LibSvg.getSvg("wearables", wearableType.svgId),
            "</svg></g>"
        );
        uint256 svgId = s.sleeves[_wearableId];
        if (svgId != 0) {
            sleeves_ = abi.encodePacked(
                // x
                LibStrings.strWithUint('"><svg x="', dimensions.x),
                // y
                LibStrings.strWithUint('" y="', dimensions.y),
                '">',
                LibSvg.getSvg("sleeves", svgId),
                "</svg>"
            );
        }
    }

    function getWearable(uint256 _wearableId, uint256 _slotPosition) internal view returns (bytes memory svg_) {
        ItemType storage wearableType = s.itemTypes[_wearableId];
        Dimensions memory dimensions = wearableType.dimensions;

        string memory wearableClass = getWearableClass(_slotPosition);

        svg_ = abi.encodePacked(
            '<g class="gotchi-wearable ',
            wearableClass,
            // x
            LibStrings.strWithUint('"><svg x="', dimensions.x),
            // y
            LibStrings.strWithUint('" y="', dimensions.y),
            '">'
        );
        if (_slotPosition == LibItems.WEARABLE_SLOT_HAND_RIGHT) {
            svg_ = abi.encodePacked(
                svg_,
                LibStrings.strWithUint('<g transform="scale(-1, 1) translate(-', 64 - (dimensions.x * 2)),
                ', 0)">',
                LibSvg.getSvg("wearables", wearableType.svgId),
                "</g></svg></g>"
            );
        } else {
            svg_ = abi.encodePacked(svg_, LibSvg.getSvg("wearables", wearableType.svgId), "</svg></g>");
        }
    }

    struct PostGetLayers {
        bytes background;
        bytes bodyWearable;
        bytes hands;
        bytes face;
        bytes eyes;
        bytes head;
        bytes sleeves;
        bytes handLeft;
        bytes handRight;
        bytes pet;
    }

    ///@notice Allow the preview of an postget given the haunt id,a set of traits,wearables and collateral type
    ///@param _hauntId Haunt id to use in preview /
    ///@param _collateralType The type of collateral to use
    ///@param _numericTraits The numeric traits to use for the postget
    ///@param equippedWearables The set of wearables to wear for the postget
    ///@return ag_ The final svg string being generated based on the given test parameters

    function previewPostGet(
        uint256 _hauntId,
        address _collateralType,
        int16[NUMERIC_TRAITS_NUM] memory _numericTraits,
        uint16[EQUIPPED_WEARABLE_SLOTS] memory equippedWearables
    ) external view returns (string memory ag_) {
        //Get base body layers
        bytes memory svg_ = getPostGetSvgLayers(_collateralType, _numericTraits, type(uint256).max - 1, _hauntId);

        //Add on body wearables
        svg_ = abi.encodePacked(addBodyAndWearableSvgLayers(svg_, equippedWearables));

        //Encode
        ag_ = string(abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">', svg_, "</svg>"));
    }

    function addBodyAndWearableSvgLayers(bytes memory _body, uint16[EQUIPPED_WEARABLE_SLOTS] memory equippedWearables)
        internal
        view
        returns (bytes memory svg_)
    {
        PostGetLayers memory layers;

        // If background is equipped
        uint256 wearableId = equippedWearables[LibItems.WEARABLE_SLOT_BG];
        if (wearableId != 0) {
            layers.background = getWearable(wearableId, LibItems.WEARABLE_SLOT_BG);
        } else {
            layers.background = LibSvg.getSvg("postget", 4);
        }

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_BODY];
        if (wearableId != 0) {
            (layers.bodyWearable, layers.sleeves) = getBodyWearable(wearableId);
        }

        // get hands
        layers.hands = abi.encodePacked(svg_, LibSvg.getSvg("postget", LibSvg.HANDS_SVG_ID));

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_FACE];
        if (wearableId != 0) {
            layers.face = getWearable(wearableId, LibItems.WEARABLE_SLOT_FACE);
        }

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_EYES];
        if (wearableId != 0) {
            layers.eyes = getWearable(wearableId, LibItems.WEARABLE_SLOT_EYES);
        }

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_HEAD];
        if (wearableId != 0) {
            layers.head = getWearable(wearableId, LibItems.WEARABLE_SLOT_HEAD);
        }

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_HAND_LEFT];
        if (wearableId != 0) {
            layers.handLeft = getWearable(wearableId, LibItems.WEARABLE_SLOT_HAND_LEFT);
        }

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_HAND_RIGHT];
        if (wearableId != 0) {
            layers.handRight = getWearable(wearableId, LibItems.WEARABLE_SLOT_HAND_RIGHT);
        }

        wearableId = equippedWearables[LibItems.WEARABLE_SLOT_PET];
        if (wearableId != 0) {
            layers.pet = getWearable(wearableId, LibItems.WEARABLE_SLOT_PET);
        }

        //1. Background wearable
        //2. Body
        //3. Body wearable
        //4. Hands
        //5. Face
        //6. Eyes
        //7. Head
        //8. Sleeves of body wearable
        //9. Left hand wearable
        //10. Right hand wearable
        //11. Pet wearable

        svg_ = abi.encodePacked(layers.background, _body, layers.bodyWearable);
        svg_ = abi.encodePacked(
            svg_,
            layers.hands,
            layers.face,
            layers.eyes,
            layers.head,
            layers.sleeves,
            layers.handLeft,
            layers.handRight,
            layers.pet
        );
    }

    ///@notice Query the svg data for all postgets with the portals as bg (10 in total)
    ///@dev This is only valid for opened and unclaimed portals
    ///@param _tokenId the identifier of the NFT(opened portal)
    ///@return svg_ An array containing the svg strings for eeach of the postgets inside the portal //10 in total
    function portalPostGetsSvg(uint256 _tokenId) external view returns (string[PORTAL_POSTGETS_NUM] memory svg_) {
        require(s.postgets[_tokenId].status == LibPostGet.STATUS_OPEN_PORTAL, "PostGetFacet: Portal not open");

        uint256 hauntId = s.postgets[_tokenId].hauntId;
        PortalPostGetTraitsIO[PORTAL_POSTGETS_NUM] memory l_portalPostGetTraits = LibPostGet.portalPostGetTraits(_tokenId);
        for (uint256 i; i < svg_.length; i++) {
            address collateralType = l_portalPostGetTraits[i].collateralType;
            svg_[i] = string(
                abi.encodePacked(
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">',
                    getPostGetSvgLayers(collateralType, l_portalPostGetTraits[i].numericTraits, type(uint256).max, hauntId),
                    // get hands
                    LibSvg.getSvg("postget", 3),
                    "</svg>"
                )
            );
        }
    }

    ///@notice Query the svg data for a particular item
    ///@dev Will throw if that item does not exist
    ///@param _svgType the type of svg
    ///@param _itemId The identifier of the item to query
    ///@return svg_ The svg string for the item
    function getSvg(bytes32 _svgType, uint256 _itemId) external view returns (string memory svg_) {
        svg_ = string(LibSvg.getSvg(_svgType, _itemId));
    }

    ///@notice Query the svg data for a multiple items of the same type
    ///@dev Will throw if one of the items does not exist
    ///@param _svgType The type of svg
    ///@param _itemIds The identifiers of the items to query
    ///@return svgs_ An array containing the svg strings for each item queried
    function getSvgs(bytes32 _svgType, uint256[] calldata _itemIds) external view returns (string[] memory svgs_) {
        uint256 length = _itemIds.length;
        svgs_ = new string[](length);
        for (uint256 i; i < length; i++) {
            svgs_[i] = string(LibSvg.getSvg(_svgType, _itemIds[i]));
        }
    }

    ///@notice Query the svg data for a particular item (with dimensions)
    ///@dev Will throw if that item does not exist
    ///@param _itemId The identifier of the item to query
    ///@return ag_ The svg string for the item
    function getItemSvg(uint256 _itemId) external view returns (string memory ag_) {
        require(_itemId < s.itemTypes.length, "ItemsFacet: _id not found for item");
        bytes memory svg;
        svg = LibSvg.getSvg("wearables", _itemId);
        // uint256 dimensions = s.itemTypes[_itemId].dimensions;
        Dimensions storage dimensions = s.itemTypes[_itemId].dimensions;
        ag_ = string(
            abi.encodePacked(
                // width
                LibStrings.strWithUint('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ', dimensions.width),
                // height
                LibStrings.strWithUint(" ", dimensions.height),
                '">',
                svg,
                "</svg>"
            )
        );
    }

    /***********************************|
   |             Write Functions        |
   |__________________________________*/

    ///@notice Allow an item manager to store a new  svg
    ///@param _svg the new svg string
    ///@param _typesAndSizes An array of structs, each struct containing the types and sizes data for `_svg`
    function storeSvg(string calldata _svg, LibSvg.SvgTypeAndSizes[] calldata _typesAndSizes) external onlyItemManager {
        LibSvg.storeSvg(_svg, _typesAndSizes);
    }

    ///@notice Allow an item manager to update an existing svg
    ///@param _svg the new svg string
    ///@param _typesAndIdsAndSizes An array of structs, each struct containing the types,identifier and sizes data for `_svg`

    function updateSvg(string calldata _svg, LibSvg.SvgTypeAndIdsAndSizes[] calldata _typesAndIdsAndSizes) external onlyItemManager {
        LibSvg.updateSvg(_svg, _typesAndIdsAndSizes);
    }

    ///@notice Allow  an item manager to delete the svg layers of an  svg
    ///@param _svgType The type of svg
    ///@param _numLayers The number of layers to delete (from the last one)
    function deleteLastSvgLayers(bytes32 _svgType, uint256 _numLayers) external onlyItemManager {
        for (uint256 i; i < _numLayers; i++) {
            s.svgLayers[_svgType].pop();
        }
    }

    struct Sleeve {
        uint256 sleeveId;
        uint256 wearableId;
    }

    ///@notice Allow  an item manager to set the sleeves of multiple items at once
    ///@dev each sleeve in `_sleeves` already contains the `_itemId` to apply to
    ///@param _sleeves An array of structs,each struct containing details about the new sleeves of each item `
    function setSleeves(Sleeve[] calldata _sleeves) external onlyItemManager {
        for (uint256 i; i < _sleeves.length; i++) {
            s.sleeves[_sleeves[i].wearableId] = _sleeves[i].sleeveId;
        }
    }

    ///@notice Allow  an item manager to set the dimensions of multiple items at once
    ///@param _itemIds The identifiers of the items whose dimensions are to be set
    ///@param _dimensions An array of structs,each struct containing details about the new dimensions of each item in `_itemIds`

    function setItemsDimensions(uint256[] calldata _itemIds, Dimensions[] calldata _dimensions) external onlyItemManager {
        require(_itemIds.length == _dimensions.length, "SvgFacet: _itemIds not same length as _dimensions");
        for (uint256 i; i < _itemIds.length; i++) {
            s.itemTypes[_itemIds[i]].dimensions = _dimensions[i];
        }
    }
}