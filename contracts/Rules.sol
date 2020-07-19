pragma solidity ^0.5.1;

contract Rules {
    uint public percentageFee = 5;
    uint dollarToWeiRate = 4242802476308100;

    function amountToPayUpfront() public view returns (uint) {
        return dollarToWeiRate * 200;
    }
}
