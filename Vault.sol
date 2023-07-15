// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Vault {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public auth;
    address public owner;
    address public tknContract;

    uint256 private unlockedBalance;
    uint256 private totalBalance;
    uint256 private startTime;

    uint256 private totalWithdraw;
    uint256 private initialTotal;

    uint256 public c_i = 9930; //decimal 4 (1 - 10000)
    uint256 public c_t = 680; // 1-1825
    uint256 public c_y0 = 5; //decimal 1 (0 - 1000)

    event Withdraw(address withdrawer, uint256 amount);

    /**
    @notice set inital parameters for this contract
    @param _c_i Concave (0 ~ 10000)
    @param _c_t Days (1 ~ 1825)
    @param _c_y0 Starting Point (0 ~ 1000) decimal
    */
    constructor(uint256 _c_i, uint256 _c_t, uint256 _c_y0) {
        auth = msg.sender;
        c_t = _c_t;
        c_i = _c_i;
        c_y0 = _c_y0;
    }

    /**
    @notice Set Token contract address
    @param _TknContract Token Contract Address
    */
    function setTkn(address _TknContract) public {
        require(tknContract == address(0), "tknContract is setted!");
        require(msg.sender == auth, "msg.sender is not Auth!");
        tknContract = _TknContract;

        startTime = block.timestamp;
    }

    /**
    @notice Set Owner
    @param _owner Owner who can withdraw tokens
    */
    function setOwner(address _owner) public {
        require(owner == address(0), "owner is setted!");
        require(msg.sender == auth, "msg.sender is not Auth!");
        owner = _owner;
    }

    /**
    @notice Get unlockedBalance and totalBalance for realtime
    */
    function getUnlocked_TotalBalance() public view returns (uint256, uint256){
        uint256 period = (block.timestamp - startTime) / 1 days;
        uint256 temp_unlock = IERC20(tknContract).balanceOf(address(this));

        if (initialTotal != 0)
            temp_unlock = initialTotal;

        if (period > c_t) period = c_t;

        uint256 b = 10 ** 18;
        uint256 a3_1 = b;
        uint256 a3_2;
        uint256 a3;
        
        for(uint16 k = 0; k < c_t; k ++){
            a3_1 *= c_i;
            a3_1 /= 10000;
        }
        a3_2 = b - a3_1;

        a3 = temp_unlock * a3_1 / a3_2;
        
        uint256 a1 = (1000 - c_y0);

        uint256 a2_1 = b;
        for (uint16 k = 0; k < period; k ++){
            a2_1 *= c_i;
            a2_1 /= 10000;
        }
        uint256 a2_2 = a2_1;
        a2_1 = b - a2_1;

        temp_unlock = a3 * a1 * a2_1 / a2_2 / 1000 + c_y0 * temp_unlock / 1000;

        if (period == c_t) temp_unlock = initialTotal;

        return (temp_unlock - totalWithdraw, IERC20(tknContract).balanceOf(address(this)));        
    }
    
    /**
    @notice withdraw token to destination address
    @param dest destination address
    @param amount amount of tokens
    */
    function withdraw(address dest, uint256 amount) public {
        if (initialTotal == 0) initialTotal = IERC20(tknContract).balanceOf(address(this));
        (unlockedBalance, totalBalance) = getUnlocked_TotalBalance();
        require(msg.sender == owner, "msg.sender is not Owner!");
        require(unlockedBalance > 0, "unlockedBalance is 0");
        require(amount <= unlockedBalance, "unlockedBalance is bigger");
        totalBalance -= amount;
        unlockedBalance -=amount;
        totalWithdraw += amount;

        (bool success, bytes memory returndata) = tknContract.call(
            abi.encodeWithSignature("transfer(address,uint256)", dest, amount)
        );
        require(success, "token transfer failed");

        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "token transfer failed");
        }
        emit Withdraw(dest, amount);
    }
}
