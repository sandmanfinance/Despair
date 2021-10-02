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

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import "@uniswap/v2-periphery/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Liquidity is Ownable {
    
    IERC20 public USDC   = IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
    IERC20 public WMATIC = IERC20(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
    IERC20 public DESPAIR;
    IUniswapV2Router02 ROUTER = IUniswapV2Router02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);
    uint256  slippageFactor = 950; // 5% default slippage tolerance

    address[] usdcToWmaticPath = [address(USDC), address(WMATIC)];

    constructor(
      address _DESPAIR
    ) {
      DESPAIR = IERC20(_DESPAIR);
      _allowance();
    }

  receive() external payable {}

  function withdrawDespairLiquidity() external onlyOwner {
      USDC.transfer(msg.sender, USDC.balanceOf(address(this)));
      DESPAIR.transfer(msg.sender, DESPAIR.balanceOf(address(this)));
  }


  function withdrawETHLiquidity()  external onlyOwner {
      uint256 etherBalance = address(this).balance;
      payable(msg.sender).transfer(etherBalance);
  }

 function withdrawAll()  external onlyOwner {
      uint256 etherBalance = address(this).balance;
      payable(msg.sender).transfer(etherBalance);
      USDC.transfer(msg.sender, USDC.balanceOf(address(this)));
      DESPAIR.transfer(msg.sender, DESPAIR.balanceOf(address(this)));
  }


  function _safeSwapWmatic (
      uint256 _amountIn,
      address[] memory _path,
      address _to
  ) internal {
      uint256[] memory amounts = ROUTER.getAmountsOut(_amountIn, _path);
      uint256 amountOut = amounts[amounts.length - 1 ];

      ROUTER.swapExactTokensForETH(
          _amountIn,
          (amountOut * slippageFactor  / 1000),
          _path,
          _to,
          block.timestamp
      );
  }

  function AutoLiquidity() external onlyOwner {
    uint256 usdcBalanceBefore = USDC.balanceOf(address(this));

    _safeSwapWmatic(
          usdcBalanceBefore / 2,
          usdcToWmaticPath,
          address(this)
      );
    
    uint256 usdcBalanceAfter = USDC.balanceOf(address(this));
    uint256 wmaticBalance = address(this).balance;
    uint256 despairBalance = DESPAIR.balanceOf(address(this));
    uint256 halfTokenAmount = despairBalance / 2;

    if (usdcBalanceAfter > 0 && wmaticBalance > 0 && despairBalance > 0) {
        // add the liquidity despair-matic
        ROUTER.addLiquidityETH{value: wmaticBalance}(
            address(DESPAIR),
            halfTokenAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );

        // add the liquidity despair-usdc
        ROUTER.addLiquidity(
            address(DESPAIR),
            address(USDC),
            halfTokenAmount,
            usdcBalanceAfter,
            0,
            0,
            msg.sender,
            block.timestamp
        );
    }
  }

  function _allowance() internal {
    USDC.approve(address(ROUTER), type(uint256).max);
    DESPAIR.approve(address(ROUTER), type(uint256).max);
  }


}