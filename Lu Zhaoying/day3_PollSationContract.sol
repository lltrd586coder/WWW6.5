// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vote {
    string[] public candidateNames;
    mapping(string => uint256) voteCount;
    
    // 用于记录地址是否已经投票
    mapping(address => bool) public hasVoted;

    // 添加候选人
    function addCandidateNames(string memory _candidateNames) public {
        candidateNames.push(_candidateNames);
        voteCount[_candidateNames] = 0;
    }

    // 检索候选人列表
    function getCandidateNames() public view returns (string[] memory) {
        return candidateNames;
    }

    // 为候选人投票
    function vote(string memory _candidateNames) public {
        // 防止重复投票
        require(!hasVoted[msg.sender], "You have already voted.");
        
        // 检查候选人是否存在
        // 通过遍历数组来验证候选人是否在列表中
        bool candidateExists = false;
        for (uint256 i = 0; i < candidateNames.length; i++) {
            if (keccak256(abi.encodePacked(candidateNames[i])) == keccak256(abi.encodePacked(_candidateNames))) {
                candidateExists = true;
                break;
            }
        }
        require(candidateExists, "Candidate does not exist.");

        // 记录投票
        voteCount[_candidateNames] += 1;
        // 标记该地址已投票
        hasVoted[msg.sender] = true;
    }

    // 检查候选人的票数
    function getVote(string memory _candidateNames) public view returns (uint256) {
        return voteCount[_candidateNames];
    }
}
