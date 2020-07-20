pragma solidity ^0.5.1;

contract Rules {
    address payable public owner;
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
        require (percentageFee < 100, "Percentages cannot go over 100");
        require (withdrawalPercentageFee < 100, "Percentages cannot go over 100");
        require (withdrawalPenaltyPercentageFeeByDay < 100, "Percentages cannot go over 100");
        require (withdrawalPenaltyPercentageFeeByDay * withdrawalPenaltyMaxDays < 100, "Cannot charge more than 100 percent");

        percentageFee = _percentageFee;
        dollarToWeiRate = _dollarToWeiRate; //4242802476308100;
        withdrawalPercentageFee = _withdrawalPercentageFee;
        withdrawalPenaltyPercentageFeeByDay = _withdrawalPenaltyPercentageFeeByDay;
        withdrawalPenaltyMaxDays = _withdrawalPenaltyMaxDays;
        charityAddress = _charityAddress;
        owner = msg.sender;
    }

    //MODIFIERS
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this method");
        _;
    }

    //SETTERS
    function setPercentageFee(uint256 _percentageFee) public onlyOwner{
        require (percentageFee < 100, "Percentages cannot go over 100");
        percentageFee = _percentageFee;
    }

    function setDollarToWeiRate(uint256 _dollarToWeiRate) public onlyOwner{
        dollarToWeiRate = _dollarToWeiRate;
    }

    function setWithdrawalPercentageFee(uint256 _withdrawalPercentageFee) public onlyOwner{
        require (withdrawalPercentageFee < 100, "Percentages cannot go over 100");
        withdrawalPercentageFee = _withdrawalPercentageFee;
    }

    function setWithdrawalPenaltyPercentageFeeByDay(uint256 _withdrawalPenaltyPercentageFeeByDay) public onlyOwner{
        require (withdrawalPenaltyPercentageFeeByDay < 100, "Percentages cannot go over 100");
        withdrawalPenaltyPercentageFeeByDay = _withdrawalPenaltyPercentageFeeByDay;
    }

    function setWithdrawalPenaltyMaxDays(uint256 _withdrawalPenaltyMaxDays) public onlyOwner{
        withdrawalPenaltyMaxDays = _withdrawalPenaltyMaxDays;
    }

}
