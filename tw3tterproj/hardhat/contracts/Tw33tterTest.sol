//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Tw33tterTest {
    string private tw33tting;

    constructor(string memory _tw33tting) {
        console.log("Deploying a Greeter with greeting:", _tw33tting);
        tw33tting = _tw33tting;
    }

    function tw33tter() public view returns (string memory) {
        return tw33tting;
    }

    function setTw33tter(string memory _tw33tting) public {
        console.log("Changing greeting from '%s' to '%s'", tw33tting, _tw33tting);
        tw33tting = _tw33tting;
    }
}
