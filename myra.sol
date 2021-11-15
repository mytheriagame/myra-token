// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract MYRA is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, Pausable {
    
    using SafeMath for uint;

    uint256 private totalTokens;
    uint256 public maxTransferWhenAntiBot;
    bool public isAntiBotMaxBalance;
    bool public isAntiBotBlockTransfer;

    mapping(address=> bool) public whitelistBotTransfer;

    mapping(address=> bool) public whitelistBotMaxBalance;

    constructor() ERC20("Mytheria", "MYRA") {
        totalTokens = 200 * 10 ** 6 * 10 ** uint256(decimals()); // 200M
        _mint(owner(), totalTokens);  
        maxTransferWhenAntiBot = 5000 * 10 ** uint256(decimals());
    }

    function snapshot() external onlyOwner {
        _snapshot();
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override(ERC20, ERC20Snapshot)
    {
        _antiBotBlockTransfer(from);
        _antiBotMaxBalance(to, amount);
        super._beforeTokenTransfer(from, to, amount);
    }

    function _antiBotBlockTransfer(address _addr) internal view {
        if(isAntiBotBlockTransfer && !whitelistBotTransfer[_addr]){
            revert("Anti Bot");
        }
    }

    function _antiBotMaxBalance(address _addr, uint256 _amount) internal view {
        if(isAntiBotMaxBalance && !whitelistBotMaxBalance[_addr]){
            require(balanceOf(_addr).add(_amount) <= maxTransferWhenAntiBot,"Anti Bot");
        }
    }

    function getBurnedAmountTotal() external view returns (uint256 _amount) {
        return totalTokens.sub(totalSupply());
    }

    function modifyWhiteListMaxBalance(address[] calldata newWhiteList, address[] calldata removedWhiteList) external onlyOwner {
        for(uint256 index; index < newWhiteList.length; index++) {
            whitelistBotMaxBalance[newWhiteList[index]] = true;
        }
        for(uint256 index; index < removedWhiteList.length; index++) {
            whitelistBotMaxBalance[removedWhiteList[index]] = false;
        }
    }
    
    function modifyWhiteListBlockTransfer(address[] calldata newWhiteList, address[] calldata removedWhiteList) external onlyOwner {
        for(uint256 index; index < newWhiteList.length; index++) {
            whitelistBotTransfer[newWhiteList[index]] = true;
        }
        for(uint256 index; index < removedWhiteList.length; index++) {
            whitelistBotTransfer[removedWhiteList[index]] = false;
        }
    }

    function setAntiBot(bool _isAntiBlockTransfer, bool _isAntiMaxBalance) external onlyOwner {
        isAntiBotMaxBalance = _isAntiMaxBalance;
        isAntiBotBlockTransfer = _isAntiBlockTransfer;
    }

    function setMaxTransferWhenAntiBot(uint256 _max) external onlyOwner {
        maxTransferWhenAntiBot = _max;
    }
}
