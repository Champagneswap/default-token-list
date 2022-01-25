// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

// ChampagneCellar is the coolest bar in town. You come in with some Champagne, and leave with more! The longer you stay, the more Champagne you get.
//
// This contract handles swapping to and from Cristal, ChampagneSwap's staking token.
contract ChampagneCellar is ERC20("Cristal", "CRISTAL"){
    using SafeMath for uint256;
    IERC20 public cham;

    // Define the Champagne token contract
    constructor(IERC20 _cham) public {
        cham = _cham;
    }

    // Enter the bar. Pay some CHAMs. Earn some shares.
    // Locks Champagne and mints Cristal
    function enter(uint256 _amount) public {
        // Gets the amount of Champange locked in the contract
        uint256 totalCham = cham.balanceOf(address(this));
        // Gets the amount of Cristal in existence
        uint256 totalShares = totalSupply();
        // If no Cristal exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalCham == 0) {
            _mint(msg.sender, _amount);
        } 
        // Calculate and mint the amount of Cristal the Champange is worth. The ratio will change overtime, as Cristal is burned/minted and Champagne deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalCham);
            _mint(msg.sender, what);
        }
        // Lock the Champagne in the contract
        cham.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your CHAMs.
    // Unlocks the staked + gained Champagne and burns Cristal
    function leave(uint256 _share) public {
        // Gets the amount of Cristal in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of Champagne the Cristal is worth
        uint256 what = _share.mul(cham.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, _share);
        cham.transfer(msg.sender, what);
    }
}
