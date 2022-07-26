// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

error Not__Owner();
error UpKeepNotNeed(uint256 contractState);

contract AutoUpdating is VRFConsumerBaseV2, KeeperCompatible {
    //type declarations
    enum ContractState {
        NOTUPDATING,
        UPDATING
    }

    //chainlink vrf variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private immutable REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUMWORDS = 3;

    //contract state variables
    address private immutable i_owner;
    uint256 private immutable i_interval;
    struct IotStats {
        uint256 temperature;
        uint256 humidity;
        uint256 airQuality;
        uint256 updatedAt;
    }
    IotStats[] private s_iotStatsArray;
    ContractState private s_contractState;

    //events
    event IotStatsUpdated(uint256 indexed updatedTime);

    constructor(
        address vrfCoordinator,
        uint64 _subscriptionId,
        bytes32 _gasLane,
        uint32 _callbackGasLimit,
        uint256 _interval
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_owner = msg.sender;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_subscriptionId = _subscriptionId;
        i_gasLane = _gasLane;
        i_callbackGasLimit = _callbackGasLimit;
        i_interval = _interval;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Not__Owner();
        }
        _;
    }

    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        bool isNotUpdating = ContractState.NOTUPDATING == s_contractState;
        bool timePassed = (block.timestamp - getLatestUpdatedTimestamp() >
            i_interval);
        bool hasBalance = address(this).balance > 0;

        upkeepNeeded = (isNotUpdating && timePassed && hasBalance);
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        (bool upKeepNeeded, ) = checkUpkeep("");
        if (!upKeepNeeded) {
            revert UpKeepNotNeed(uint256(s_contractState));
        }
        s_contractState = ContractState.UPDATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUMWORDS
        );
    }

    function fulfillRandomWords(
        uint256, /*requestId */
        uint256[] memory randomWords
    ) internal override {
        uint256 _temperature = randomWords[0] % 3;
        uint256 _humidity = randomWords[1] % 3;
        uint256 _airQuality = randomWords[2] % 3;
        s_iotStatsArray.push(
            IotStats(_temperature, _humidity, _airQuality, block.timestamp)
        );
        emit IotStatsUpdated(block.timestamp);
    }

    // function updateIotStats(
    //     uint256 _temperature,
    //     uint256 _humidity,
    //     uint256 _airQuality,
    //     uint256
    // ) public onlyOwner {
    //     s_contractState = ContractState.UPDATING;
    //     s_iotStatsArray.push(
    //         IotStats(_temperature, _humidity, _airQuality, block.timestamp)
    //     );
    //     s_contractState = ContractState.NOTUPDATING;
    //     emit IotStatsUpdated(block.timestamp);
    // }

    function getLatestStats() public view returns (IotStats memory) {
        return s_iotStatsArray[getIotStatsArrayLength() - 1];
    }

    function getIotStatsArrayLength() public view returns (uint256) {
        uint256 arrayLength = s_iotStatsArray.length;
        return arrayLength;
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getLatestUpdatedTimestamp() public view returns (uint256) {
        return s_iotStatsArray[getIotStatsArrayLength() - 1].updatedAt;
    }
}
