pragma solidity ^0.5.1;

import "./Rules.sol";

contract Manager {
    struct Withdrawal {
        uint timestamp;
        uint amount; 
    }

    //PROPERTIES
    address payable public owner;
    address payable public account;
    bool public hasActiveWithdrawal;
    Withdrawal public withdrawal;
    Rules private _rules;

    constructor(address payable _account, Rules rules) public payable {

        owner = msg.sender;
        account = _account;
        _rules = rules;
    }

    //FALLBACK FUNCTION
    function() external payable {}
    
    //MODIFIERS
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the owner can execute this method"
        );
        _;
    }
    
    function canManage() public onlyOwner view returns(bool){
        return (!hasActiveWithdrawal || calculateWithdrawalFees() == 0);
    }
    
    //PRE: hasActiveWithdrawal
    function canPay() public onlyOwner view returns (bool){
        uint penaltyFee = calculateWithdrawalFees();
        return address(this).balance >= withdrawal.amount + penaltyFee;
    }
    
    //PRE: !hasActiveWithdrawal
    function registerWithdraw(uint _amount) public onlyOwner{
        withdrawal.timestamp = now;
        withdrawal.amount = _amount;
        hasActiveWithdrawal = true;
    }
    
    //PRE: hasActiveWithdrawal
    function payWithdraw() public onlyOwner{
        uint penaltyFee = calculateWithdrawalFees();
        uint amount = withdrawal.amount + penaltyFee;
        hasActiveWithdrawal = false;
        delete(withdrawal);
        owner.transfer(amount);
    }

    function destroy() public onlyOwner {
        selfdestruct(account);
    }
    
    //PRE: hasActiveWithdrawal
    function calculateWithdrawalFees() private view returns(uint){
        uint penaltyFee = 0;
        uint diff = (now - withdrawal.timestamp) / 60 / 60 / 24;
        if (diff > 90){
            uint penaltyDays = diff - 90;
            if (penaltyDays > _rules.withdrawalPenaltyMaxDays()){
                penaltyDays = _rules.withdrawalPenaltyMaxDays();
            }
            penaltyFee = withdrawal.amount * _rules.withdrawalPenaltyPercentageFeeByDay() * penaltyDays / 100;
        }
        return penaltyFee;
    }
}