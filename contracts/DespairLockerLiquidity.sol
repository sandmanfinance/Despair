/*
▓█████▄ ▓█████   ██████  ██▓███   ▄▄▄       ██▓ ██▀███  
▒██▀ ██▌▓█   ▀ ▒██    ▒ ▓██░  ██▒▒████▄    ▓██▒▓██ ▒ ██▒
░██   █▌▒███   ░ ▓██▄   ▓██░ ██▓▒▒██  ▀█▄  ▒██▒▓██ ░▄█ ▒
░▓█▄   ▌▒▓█  ▄   ▒   ██▒▒██▄█▓▒ ▒░██▄▄▄▄██ ░██░▒██▀▀█▄  
░▒████▓ ░▒████▒▒██████▒▒▒██▒ ░  ░ ▓█   ▓██▒░██░░██▓ ▒██▒
 ▒▒▓  ▒ ░░ ▒░ ░▒ ▒▓▒ ▒ ░▒▓▒░ ░  ░ ▒▒   ▓▒█░░▓  ░ ▒▓ ░▒▓░
 ░ ▒  ▒  ░ ░  ░░ ░▒  ░ ░░▒ ░       ▒   ▒▒ ░ ▒ ░  ░▒ ░ ▒░
 ░ ░  ░    ░   ░  ░  ░  ░░         ░   ▒    ▒ ░  ░░   ░ 
   ░       ░  ░      ░                 ░  ░ ░     ░     
 */
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DespairLockerLiquidity is Ownable {
    using SafeERC20 for IERC20;

    uint256 public immutable UNLOCK_END_BLOCK;

    event Claim(IERC20 despairToken, address to);


    /**
     * @notice Constructs the Despair contract.
     */
    constructor(uint256 blockNumber) {
        UNLOCK_END_BLOCK = blockNumber;
    }

    /**
     * @notice claimSanManLiquidity
     * claimdespairToken allows the despair Team to send despair Liquidity to the new delirum kingdom.
     * It is only callable once UNLOCK_END_BLOCK has passed.
     * Despair Liquidity Policy: https://docs.despair.farm/token-info/despair-token/liquidity-lock-policy
     */

    function claimSanManLiquidity(IERC20 despairLiquidity, address to) external onlyOwner {
        require(block.number > UNLOCK_END_BLOCK, "Despair is still dreaming...");

        despairLiquidity.safeTransfer(to, despairLiquidity.balanceOf(address(this)));

        emit Claim(despairLiquidity, to);
    }
}