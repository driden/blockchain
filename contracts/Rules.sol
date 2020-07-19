pragma solidity ^0.5.1;

contract Rules {
    uint256 public percentageFee = 5;
    uint256 dollarToWeiRate = 4242802476308100;

    function amountToPayUpfront() public view returns (uint) {
        return dollarToWeiRate * 200;
    }
}
