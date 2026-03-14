// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-IDepositBox.sol";
import "./day14-BasicDepositBox.sol";
import "./day14-PremiumDepositBox.sol";
import "./day14-TimeLockedDepositBox.sol";

contract VaultManager {
    // 用户创建了哪些boxs   
    mapping(address => address[]) private userDepositBoxes;
    mapping(address => string) private boxNames;

    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    event BoxNamed(address indexed boxAddress, string name);

    function createBasicBox() external returns (address) {
        BasicDepositBox box = new BasicDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    function createTimeLockedBox(uint256 _lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox(_lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }

    function nameBox(address _boxAddress, string calldata _name) external {
        IDepositBox box = IDepositBox(_boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        boxNames[_boxAddress] = _name;
        emit BoxNamed(_boxAddress, _name);
    }

    function storeSecret(address _boxAddress, string calldata _secret) external {
        IDepositBox box = IDepositBox(_boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.storeSecret(_secret);
    }

    function transferBoxOwnership(address _boxAddress, address _newOwner) external {
        IDepositBox box = IDepositBox(_boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.transferOwnership(_newOwner);

        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; i < boxes.length; i++) {
            if (boxes[i] == _boxAddress) {
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        }

        userDepositBoxes[_newOwner].push(_boxAddress);
    }

    function getUserBoxes(address _user) external view returns (address[] memory) {
        return userDepositBoxes[_user];
    }

    function getBoxName(address _boxAddress) external view returns (string memory) {
        return boxNames[_boxAddress];
    }

    function getBoxInfo(address _boxAddress) external view returns (
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ) {
        IDepositBox box = IDepositBox(_boxAddress);
        return (
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxNames[_boxAddress]
        );
    }
}
