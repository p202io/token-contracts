// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @custom:security-contact support@p202.io
contract P202Presale is Ownable {
    uint256 public price = 0.00011 ether;
    address public immutable token;

    constructor(address token_) {
        token = token_;
    }

    function withdraw() public onlyOwner {
        _sendEth(msg.sender, address(this).balance);
    }

    function setPrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
    }

    function buy() external payable {
        _buy(msg.value);
    }

    function _buy(uint256 ethValue) private {
        uint256 tokenAmount = (ethValue * 1 ether) / price;
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (tokenAmount > balance) {
            tokenAmount = balance;
            uint256 change = ethValue - (tokenAmount * price) / 1 ether;
            if (change > 0) {
                _sendEth(msg.sender, change);
            }
        }
        _sendErc20(msg.sender, tokenAmount);
    }

    function _sendEth(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}("");
        require(success, "ETH_FAILED_TRANSFER");
    }

    function _sendErc20(address to, uint256 amount) internal {
        bool success = IERC20(token).transfer(to, amount);
        require(success, "TOKEN_FAILED_TRANSFER");
    }

    receive() external payable {
        _buy(msg.value);
    }
}
