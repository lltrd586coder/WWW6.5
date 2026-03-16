// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// MockWeatherOracle - 模拟天气预言机合约
// 这是一个用于测试的模拟预言机，模拟 Chainlink AggregatorV3Interface
// 在实际生产环境中，应该使用真实的 Chainlink 预言机网络
contract MockWeatherOracle {
    // 数据轮次 ID，每次更新时递增
    uint80 private _roundId;

    // 降雨量数据（单位：毫米）
    // 使用 int256 以兼容 Chainlink 接口（可能返回负数表示错误）
    int256 private _rainfallData;

    // 数据更新时间戳
    uint256 private _timestamp;

    // 构造函数 - 初始化默认值
    constructor() {
        _roundId = 1;
        _timestamp = block.timestamp;
        _rainfallData = 100; // 默认降雨量 100mm
    }

    // 更新降雨量数据（仅用于测试）
    // _rainfall: 新的降雨量值（毫米）
    // 在实际 Chainlink 预言机中，此函数由预言机节点调用
    function updateRainfall(int256 _rainfall) external {
        _rainfallData = _rainfall;
        _timestamp = block.timestamp;
        _roundId++;
    }

    // 模拟 Chainlink 的 AggregatorV3Interface
    // 获取最新的数据轮次信息
    // 返回:
    //   roundId: 数据轮次 ID
    //   answer: 降雨量数据（毫米）
    //   startedAt: 轮次开始时间戳
    //   updatedAt: 数据更新时间戳
    //   answeredInRound: 回答所在的轮次
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (_roundId, _rainfallData, _timestamp, _timestamp, _roundId);
    }
}

// Chainlink 预言机说明:
//
// 1. 真实预言机 vs 模拟预言机:
//    - 模拟预言机: 用于开发和测试，可手动设置数据
//    - 真实预言机: 由去中心化网络提供数据，不可篡改
//
// 2. AggregatorV3Interface 标准:
//    - Chainlink 价格 feeds 的标准接口
//    - 提供 roundId, answer, timestamp 等信息
//    - 支持多个数据提供商的聚合
//
// 3. 使用场景:
//    - 价格预言机（ETH/USD, BTC/USD 等）
//    - 天气数据
//    - 任何需要链下数据的场景
//
// 4. 安全注意事项:
//    - 真实应用中要考虑预言机延迟和价格偏差
//    - 可能需要使用多个预言机进行交叉验证
//    - 考虑使用 Chainlink 的数据质量证明
