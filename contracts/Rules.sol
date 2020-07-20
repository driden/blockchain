pragma solidity ^0.5.1;

contract Rules {
    uint public percentageFee;
    uint public dollarToWeiRate;
    uint public withdrawalPercentageFee;
    uint public withdrawalPenaltyPercentageFeeByDay;
    uint public withdrawalPenaltyMaxDays;

    function amountToPayUpfront() public view returns (uint) {
        return dollarToWeiRate * 200;
    }

    constructor(
        // uint _percentageFee,
        // uint _dollarToWeiRate,
        // uint _withdrawalPercentageFee,
        // uint _withdrawalPenaltyPercentageFeeByDay,
        // uint _withdrawalPenaltyMaxDays
        ) public{
        //CAMBIAR HARDCODEO LUEGO
        percentageFee = 5;
        dollarToWeiRate = 4242802476308100;
        withdrawalPercentageFee = 1;
        withdrawalPenaltyPercentageFeeByDay = 1;
        withdrawalPenaltyMaxDays = 30;
    }
}
