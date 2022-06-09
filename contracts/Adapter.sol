// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/**
 * @title Adapter contract over uniswapv2 router contract
 */
contract Adapter {
    using SafeERC20 for IERC20;

    IUniswapV2Router02 public immutable router;

    constructor(address _router) {
        router = IUniswapV2Router02(_router);
    }

    /**
     * @dev Swaps exact `amountIn` amount of tokens to get minimum `amountOutMin` of tokens
     * @param amountIn The exact amount of token that swapper willing to send
     * @param amountOutMin The minimum amount of token that swapper willing to get
     * @param path The path that swap function is going to follow, first element should be input token, last element output
     * @param to The recipient of the tokens
     * @param deadline The timestamp that transaction will be reverted
     * @return amounts The input token amount and all subsequent output token amounts
     */
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

    /**
     * @dev Swaps maximum `amountInMax` amount of tokens to get exact `amountOut` of tokens
     * @param amountOut The exact amount of token that swapper willing to get
     * @param amountInMax The maximum amount of token that swapper willing to send
     * @param path The path that swap function is going to follow, first element should be input token, last element output
     * @param to The recipient of the tokens
     * @param deadline The timestamp that transaction will be reverted
     * @return amounts The input token amount and all subsequent output token amounts
     */
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

    /**
     * @dev Swaps exact amount of native tokens to get minimum `amountOutMin` of tokens
     * @param amountOutMin The minimum amount of token that swapper willing to get
     * @param path The path that swap function is going to follow, first element should be input token, last element output
     * @param to The recipient of the tokens
     * @param deadline The timestamp that transaction will be reverted
     * @return amounts The input token amount and all subsequent output token amounts
     */
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts) {
        amounts = router.swapExactETHForTokens{ value: msg.value }(amountOutMin, path, to, deadline);
    }

    /**
     * @dev Swaps maximum `amountInMax` amount of tokens to get exact `amountOut` of native tokens
     * @param amountOut The exact amount of native token that swapper willing to get
     * @param amountInMax The maximum amount of token that swapper willing to send
     * @param path The path that swap function is going to follow, first element should be input token, last element output
     * @param to The recipient of the tokens
     * @param deadline The timestamp that transaction will be reverted
     * @return amounts The input token amount and all subsequent output token amounts
     */
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        IERC20 path0 = IERC20(path[0]);

        path0.safeTransferFrom(msg.sender, address(this), amountInMax);
        path0.approve(address(router), amountInMax);

        amounts = router.swapTokensForExactETH(amountOut, amountInMax, path, to, deadline);

        path0.safeTransfer(msg.sender, amountInMax - amounts[0]);
    }

    /**
     * @dev Swaps exact `amountIn` amount of tokens to get minimum `amountOutMin` of native tokens
     * @param amountIn The exact amount of token that swapper willing to send
     * @param amountOutMin The minimum amount of native token that swapper willing to get
     * @param path The path that swap function is going to follow, first element should be input token, last element output
     * @param to The recipient of the tokens
     * @param deadline The timestamp that transaction will be reverted
     * @return amounts The input token amount and all subsequent output token amounts
     */
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        IERC20 path0 = IERC20(path[0]);

        path0.safeTransferFrom(msg.sender, address(this), amountIn);
        path0.approve(address(router), amountIn);

        amounts = router.swapExactTokensForETH(amountIn, amountOutMin, path, to, deadline);
    }

    /**
     * @dev Swaps maximum amount of native tokens to get exact `amountOut` of tokens
     * @param amountOut The exact amount of token that swapper willing to get
     * @param path The path that swap function is going to follow, first element should be input token, last element output
     * @param to The recipient of the tokens
     * @param deadline The timestamp that transaction will be reverted
     * @return amounts The input token amount and all subsequent output token amounts
     */
    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts) {
        amounts = router.swapETHForExactTokens{ value: msg.value }(amountOut, path, to, deadline);

        payable(msg.sender).transfer(msg.value - amounts[0]);
    }

    /**
     * @dev Given amount of input tokens, returns amount of output tokens
     * @param amountIn Amount of input tokens
     * @param path The path that function is going to follow, first element should be input token, last element output
     * @return amounts The input token amount and all subsequent output token amounts
     */
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts) {
        amounts = router.getAmountsOut(amountIn, path);
    }

    /**
     * @dev Given amount of output tokens, returns amount of input tokens
     * @param amountOut Amount of output tokens
     * @param path The path that function is going to follow, first element should be input token, last element output
     * @return amounts The input token amount and all subsequent output token amounts
     */
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts) {
        amounts = router.getAmountsIn(amountOut, path);
    }
}
