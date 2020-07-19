pragma solidity ^0.5.1;

contract Manager {
    struct Withdrawal {
        uint timestamp;
        uint amount; 
    }
    bool private _canManage;

    //PROPERTIES
    address payable public owner;
    address payable public account;
    bool public hasActiveWithdrawal;
    Withdrawal public withdrawal;

    constructor(address payable _account) public payable {
        _canManage = true;
        owner = msg.sender;
        account = _account;
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
        return _canManage;
    }

    function canPay() public onlyOwner view returns (bool){
        return address(this).balance >= withdrawal.amount;
    }

    function registerWithdraw(uint _amount) public onlyOwner{
        withdrawal.timestamp = block.timestamp;
        withdrawal.amount = _amount;
        hasActiveWithdrawal = true;
    }

    function payWithdraw() public onlyOwner{
        uint amount = withdrawal.amount;
        hasActiveWithdrawal = false;
        delete(withdrawal);
        owner.transfer(amount);
    }

    function destroy() public onlyOwner {
        selfdestruct(account);
    }
}