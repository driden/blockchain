pragma solidity ^0.5.1;

contract Rules {
    address[] public membersOfJusticeDept ;
    uint public percentageFee ;

    constructor() public{       
        percentageFee = 5;
    }
}