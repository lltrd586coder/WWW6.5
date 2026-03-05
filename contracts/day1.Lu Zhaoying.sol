// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClickCounter {
    // 状态变量：公共计数器
    uint256 public counter;

    // 1. 重置函数：将计数器设为 0
    function reset() public {
        counter = 0;
    }

    // 2. 减少函数：计数器减 1，防止下溢（不能小于 0）
    function decrease() public {
        require(counter > 0, "Counter cannot be less than 0");
        counter--;
    }

    // 3. 查询函数：明确返回当前计数值 (使用 View 修饰符)
    function getCounter() public view returns (uint256) {
        return counter;
    }

    // 4. 批量增加函数：一次增加指定的次数
    function clickMultiple(uint256 times) public {
        require(times > 0, "Times must be greater than 0");
        counter += times;
    }

    // 原有的增加函数 (保留)
    function click() public {
        counter++;
    }
}

