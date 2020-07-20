pragma solidity ^0.5.1;

contract Rules {
    uint256 public percentageFee;
    uint256 public dollarToWeiRate;
    uint256 public withdrawalPercentageFee;
    uint256 public withdrawalPenaltyPercentageFeeByDay;
    uint256 public withdrawalPenaltyMaxDays;
    address payable public charityAddress;

    function amountToPayUpfront() public view returns (uint256) {
        return dollarToWeiRate * 200;
    }

    constructor(
        uint256 _percentageFee,
        uint256 _dollarToWeiRate,
        uint256 _withdrawalPercentageFee,
        uint256 _withdrawalPenaltyPercentageFeeByDay,
        uint256 _withdrawalPenaltyMaxDays,
        address payable _charityAddress
    ) public {
        percentageFee = _percentageFee;
        dollarToWeiRate = _dollarToWeiRate; //4242802476308100;
        withdrawalPercentageFee = _withdrawalPercentageFee;
        withdrawalPenaltyPercentageFeeByDay = _withdrawalPenaltyPercentageFeeByDay;
        withdrawalPenaltyMaxDays = _withdrawalPenaltyMaxDays;
        charityAddress = _charityAddress;
    }
}
