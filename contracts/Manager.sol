pragma solidity ^0.5.1;

import "./Rules.sol";

contract Manager {
    struct Withdrawal {
        uint256 timestamp;
        uint256 amount;
        string reason;
    }

    event WithdrawalDone(address indexed from, uint256 amount, string reason);

    //PROPERTIES
    address payable public owner;
    address payable public account;
    bool public hasActiveWithdrawal;
    bool public hasReportedOwnerDeath;
    uint256 public reportedOwnerDeathDate;

    Withdrawal public withdrawal;
    Rules private _rules;

    Withdrawal[] public managerWithdrawals;

    constructor(address payable _account, Rules rules) public payable {
        owner = msg.sender;
        account = _account;
        _rules = rules;
    }

    //FALLBACK FUNCTION
    function() external payable {}

    //MODIFIERS
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this method");
        _;
    }

    function canManage() public view onlyOwner returns (bool) {
        return (!hasActiveWithdrawal || calculateWithdrawalFees() == 0);
    }

    //PRE: hasActiveWithdrawal
    function canPay() public view onlyOwner returns (bool) {
        uint256 penaltyFee = calculateWithdrawalFees();
        return address(this).balance >= withdrawal.amount + penaltyFee;
    }

    //PRE: !hasActiveWithdrawal
    function registerWithdraw(string memory _reason, uint256 _amount)
        public
        onlyOwner
    {
        withdrawal.timestamp = now;
        withdrawal.amount = _amount;
        hasActiveWithdrawal = true;

        managerWithdrawals.push(
            Withdrawal({timestamp: now, amount: _amount, reason: _reason})
        );

        emit WithdrawalDone(msg.sender, _amount, _reason);
    }

    //PRE: hasActiveWithdrawal
    function payWithdraw() public onlyOwner {
        uint256 penaltyFee = calculateWithdrawalFees();
        uint256 amount = withdrawal.amount + penaltyFee;
        hasActiveWithdrawal = false;
        delete (withdrawal);
        owner.transfer(amount);
    }

    function destroy() public onlyOwner {
        selfdestruct(account);
    }

    //PRE: hasActiveWithdrawal
    function calculateWithdrawalFees() private view returns (uint256) {
        uint256 penaltyFee = 0;
        uint256 diff = (now - withdrawal.timestamp) / 60 / 60 / 24;
        if (diff > 90) {
            uint256 penaltyDays = diff - 90;
            if (penaltyDays > _rules.withdrawalPenaltyMaxDays()) {
                penaltyDays = _rules.withdrawalPenaltyMaxDays();
            }
            penaltyFee =
                (withdrawal.amount *
                    _rules.withdrawalPenaltyPercentageFeeByDay() *
                    penaltyDays) /
                100;
        }
        return penaltyFee;
    }

    function cleanOwnerDeathReport() public onlyOwner {
        hasReportedOwnerDeath = false;
        delete (reportedOwnerDeathDate);
    }

    function reportOwnersDeath() public onlyOwner {
        hasReportedOwnerDeath = true;
        reportedOwnerDeathDate = now;
    }

    function withdrawalAmount() public view returns (uint256) {
        return withdrawal.amount;
    }
}
