// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Adapter contract with fee over uniswapv2 router contract
 */
contract AdapterWithFee is Ownable {
    using SafeERC20 for IERC20;

    uint96 private constant _FEE_DENOMINATOR = 10000; // means 100

    IUniswapV2Router02 public immutable router;

    uint96 public fee = 500;

    constructor(address _router) {
        router = IUniswapV2Router02(_router);
    }

    function setFee(uint96 _fee) external onlyOwner {
        fee = _fee;
    }

    function withdrawFeesToken(address _tokenContract) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        uint256 availableAmount = tokenContract.balanceOf(address(this));

        tokenContract.safeTransfer(msg.sender, availableAmount);
    }

    function withdrawFeesNative() external onlyOwner {
        uint256 amount = address(this).balance;

        payable(msg.sender).transfer(amount);
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

        uint256 feeTransfer = _getFee(amountIn);
        uint256 dexTransfer = amountIn - feeTransfer;

        path0.approve(address(router), dexTransfer);

        amounts = router.swapExactTokensForTokens(dexTransfer, amountOutMin, path, to, deadline);
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

        // to get amount without fee (so amount * 1) / (1 + fee) ex(%5 fee) amount / 1.05
        uint256 amountToSendRouter = (amountInMax * _FEE_DENOMINATOR) / (_FEE_DENOMINATOR + fee);

        path0.approve(address(router), amountToSendRouter);
        amounts = router.swapTokensForExactTokens(amountOut, amountToSendRouter, path, to, deadline);

        uint256 feeTransfer = _getFee(amounts[0]);
        uint256 userTransfer = amountInMax - (amounts[0] + feeTransfer);

        path0.safeTransfer(msg.sender, userTransfer);
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
        uint256 feeTransfer = _getFee(msg.value);
        uint256 dexTransfer = msg.value - feeTransfer;

        amounts = router.swapExactETHForTokens{ value: dexTransfer }(amountOutMin, path, to, deadline);
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

        // to get amount without fee (so amount * 1) / (1 + fee) ex(%5 fee) amount / 1.05
        uint256 amountToSendRouter = (amountInMax * _FEE_DENOMINATOR) / (_FEE_DENOMINATOR + fee);

        path0.approve(address(router), amountToSendRouter);
        amounts = router.swapTokensForExactETH(amountOut, amountToSendRouter, path, to, deadline);

        uint256 feeTransfer = _getFee(amounts[0]);
        uint256 userTransfer = amountInMax - (amounts[0] + feeTransfer);

        path0.safeTransfer(msg.sender, userTransfer);
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

        uint256 feeTransfer = _getFee(amountIn);
        uint256 dexTransfer = amountIn - feeTransfer;

        path0.approve(address(router), dexTransfer);

        amounts = router.swapExactTokensForETH(dexTransfer, amountOutMin, path, to, deadline);
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
        // to get amount without fee (so amount * 1) / (1 + fee) ex(%5 fee) amount / 1.05
        uint256 amountToSendRouter = (msg.value * _FEE_DENOMINATOR) / (_FEE_DENOMINATOR + fee);
        amounts = router.swapETHForExactTokens{ value: amountToSendRouter }(amountOut, path, to, deadline);

        uint256 feeTransfer = _getFee(amounts[0]);
        uint256 userTransfer = msg.value - (amounts[0] + feeTransfer);

        payable(msg.sender).transfer(userTransfer);
    }

    /**
     * @dev Given amount of input tokens, returns amount of output tokens
     * @param amountIn Amount of input tokens
     * @param path The path that function is going to follow, first element should be input token, last element output
     * @return amounts The input token amount and all subsequent output token amounts
     */
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts) {
        uint256 feeTransfer = _getFee(amountIn);
        uint256 dexTransfer = amountIn - feeTransfer;

        amounts = router.getAmountsOut(dexTransfer, path);
    }

    /**
     * @dev Given amount of output tokens, returns amount of input tokens
     * @param amountOut Amount of output tokens
     * @param path The path that function is going to follow, first element should be input token, last element output
     * @return amounts The input token amount and all subsequent output token amounts
     */
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts) {
        amounts = router.getAmountsIn(amountOut, path);

        uint256 feeTransfer = _getFee(amounts[0]);
        amounts[0] += feeTransfer;
    }

    function _getFee(uint256 amount) private view returns (uint256 calculatedFee) {
        calculatedFee = (amount * fee) / _FEE_DENOMINATOR;
    }
}
