// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Adapter {
    IUniswapV2Factory public immutable factory;
    IUniswapV2Router02 public immutable router;

    constructor(address _factory, address _router) {
        factory = IUniswapV2Factory(_factory);
        router = IUniswapV2Router02(_router);
    }
}
