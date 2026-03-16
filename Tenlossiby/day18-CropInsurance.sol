// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// IWeatherOracle - 天气预言机接口
// 模拟 Chainlink 的 AggregatorV3Interface 接口
// 用于获取外部数据（降雨量）
interface IWeatherOracle {
    // 获取最新的数据轮次信息
    // 返回:
    //   roundId: 数据轮次 ID
    //   answer: 数据值（这里是降雨量，单位毫米）
    //   startedAt: 轮次开始时间
    //   updatedAt: 数据更新时间
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
        );
}

// CropInsurance - 农作物保险合约
// 这是一个参数保险（Parametric Insurance）合约
// 当降雨量低于阈值时自动赔付，无需人工审核
contract CropInsurance {
    // 天气预言机合约地址
    IWeatherOracle public weatherOracle;

    // 常量定义
    uint256 public constant RAINFALL_THRESHOLD = 50; // 降雨阈值（毫米）
    uint256 public constant PAYOUT_AMOUNT = 1 ether;  // 赔付金额（1 ETH）
    uint256 public constant PREMIUM = 0.1 ether;      // 保费（0.1 ETH）

    // 存储已购买保险的用户
    // key: 用户地址
    // value: 是否有有效保单
    mapping(address => bool) public policies;

    // 构造函数
    // _oracleAddress: 天气预言机合约地址
    constructor(address _oracleAddress) {
        weatherOracle = IWeatherOracle(_oracleAddress);
    }

    // 接收 ETH 的函数
    // 用于向保险池充值资金
    receive() external payable {}

    // 购买保险
    // 需要支付 0.1 ETH 保费
    // 每个地址只能购买一份有效保单
    function purchasePolicy() external payable {
        // 验证支付的保费金额正确
        require(msg.value == PREMIUM, "Incorrect premium amount");

        // 验证该地址没有已激活的保单
        require(!policies[msg.sender], "Policy already active");

        // 激活保单
        policies[msg.sender] = true;
    }

    // 检查降雨量并索赔
    // 用户主动调用此函数来检查条件并领取赔付
    // 如果降雨量低于阈值，自动获得赔付
    function checkRainfallAndClaim() external {
        // 验证用户有有效保单
        require(policies[msg.sender], "No active policy");

        // 从预言机获取最新降雨量数据
        (, int256 rainfall, , , ) = weatherOracle.latestRoundData();

        // 验证降雨量低于阈值（干旱条件）
        require(rainfall < int256(RAINFALL_THRESHOLD), "Rainfall sufficient, no payout");

        // 验证合约有足够资金进行赔付
        require(address(this).balance >= PAYOUT_AMOUNT, "Insufficient funds in contract");

        // 标记保单为已处理（防止重复索赔）
        // 注意: 在发送 ETH 之前更新状态，防止重入攻击
        policies[msg.sender] = false;

        // 执行赔付转账
        // 修改说明: 原代码使用 transfer()，但 Solidity 0.8.19+ 已弃用 transfer()
        // 原因: transfer() 固定只转发 2300 gas，如果接收方合约需要更多 gas 会失败
        // 新代码使用 call{value: amount}("")，更灵活且兼容性好
        // 注意: call 不会自动回滚，需要手动检查返回值
        (bool success, ) = payable(msg.sender).call{value: PAYOUT_AMOUNT}("");
        require(success, "ETH transfer failed");
    }
}

// 参数保险特点:
//
// 1. 自动执行:
//    - 基于客观数据（降雨量）自动触发赔付
//    - 无需人工审核或损失评估
//
// 2. 预言机依赖:
//    - 依赖外部数据源（天气数据）
//    - 需要信任预言机的准确性
//
// 3. 风险池:
//    - 合约需要保持足够的资金储备
//    - 保费收入应该能够覆盖预期赔付
//
// 4. 使用场景:
//    - 农作物干旱保险
//    - 航班延误保险
//    - 任何可量化参数的风险
