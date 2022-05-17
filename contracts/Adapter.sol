// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Adapter {
    using SafeERC20 for IERC20;

    IUniswapV2Factory public immutable factory;
    IUniswapV2Router02 public immutable router;

    constructor(address _factory, address _router) {
        factory = IUniswapV2Factory(_factory);
        router = IUniswapV2Router02(_router);
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        IERC20 path0 = IERC20(path[0]);

        path0.safeTransferFrom(msg.sender, address(this), amountIn);
        path0.approve(address(router), amountIn);

        amounts = router.swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        IERC20 path0 = IERC20(path[0]);

        path0.safeTransferFrom(msg.sender, address(this), amountInMax);
        path0.approve(address(router), amountInMax);

        amounts = router.swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline);

        path0.safeTransfer(msg.sender, amountInMax - amounts[0]);
    }
}
