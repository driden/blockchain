pragma solidity ^0.5.1;

import "./Rules.sol";
import "./Manager.sol";

contract Inherit {
    //DATA-STRUCTURES
    struct Person {
        uint ci;
        uint birthDate;
        string addressP;
        address payable addresEth;
        string phoneNumber;
        string email;
        uint hireDate;
        uint lastSignal;
    }

    struct Heir {
        bool isValid;
        address payable account;
        uint percentage;
        uint payoutOrder;
    }

    struct ManagerStruct {
        bool isValid;
        address payable contractAccount;
        uint arrayKey;
    }

    //PROPERTIES

    Person public owner;

    uint public amountHeirs = 0;
    mapping(address => Heir) public heirs;
    mapping(uint => address) public heirsOrder;

    uint public amountManagers = 0;
    mapping(address => ManagerStruct) public managers; //KEY: Address externa
    address[5] private managerskeys ;

    bool private amountInheritanceIsPublic = true;

    uint private remainingPercentage = 100;

    uint public cancellationPercentage; //Parametro en constructor
    uint public managersPercentageFee; //Parametro en constructor
    uint public withdrawalPercentageAllowed; //Parametro en constructor

    Rules private rules;
    address payable public companyAddress;
    

    //INITIALIZATION
    constructor(
        uint ci,
        uint birthDate,
        string memory addressP,
        string memory phoneNumber,
        string memory email,
        uint hireDate,
        uint _cancellationPercentage, 
        uint _managersPercentageFee,
        uint _withdrawalPercentageAllowed,
        address payable _companyAddress,
        address _rulesAddress
    ) public payable {
        rules = Rules(_rulesAddress);
        uint amtForTheCompany = rules.amountToPayUpfront();
        require(
            address(this).balance > amtForTheCompany,
            "Not enough funds to instance the contract."
        );

        owner = Person({
            ci: ci,
            birthDate: birthDate,
            hireDate: hireDate,
            addressP: addressP,
            addresEth: msg.sender,
            phoneNumber: phoneNumber,
            email: email,
            lastSignal: now
        });

        cancellationPercentage = _cancellationPercentage;
        managersPercentageFee = _managersPercentageFee;
        withdrawalPercentageAllowed = _withdrawalPercentageAllowed;

        companyAddress = _companyAddress;
        companyAddress.transfer(amtForTheCompany);
    }

    //FALLBACK FUNCTION
    function() external payable {}

    //GETTERS & SETTERS
    function amountInheritance() public view publicFiltered returns (uint) {
        return
            address(this).balance -
            ((uint(managersPercentageFee) *
                uint(amountManagers) *
                uint(address(this).balance)) / uint(100));
    }

    function setAmountInheritanceVisibility(bool isVisible) public onlyOwner {
        amountInheritanceIsPublic = isVisible;
    }

    //MODIFIERS
    modifier onlyOwner() {
        require(
            msg.sender == owner.addresEth,
            "Only the owner can execute this method"
        );
        _;
    }

    modifier onlyListedManagers() {
        require (managers[msg.sender].isValid, "Only listed managers can execute this method");
        _;
    }

    modifier canManage() {
        require (managers[msg.sender].isValid, "Only listed managers can execute this method");
        Manager manager = Manager(managers[msg.sender].contractAccount);
        require (manager.canManage());
        _;
    }
    
    modifier isParticipant(){
        require(heirs[msg.sender].isValid || managers[msg.sender].isValid);
        if (managers[msg.sender].isValid){
            Manager manager = Manager(managers[msg.sender].contractAccount);
            require (manager.canManage());
        }
        _;
    }
    
    modifier publicFiltered() { 
        if (!amountInheritanceIsPublic) {
            require(
                heirs[msg.sender].isValid || msg.sender == owner.addresEth,
                "Only the owner or an heir can execute this method"
            );
        }
        _;
    }

    //FUNCTIONS
    function addHeir(
        address payable heirAccount,
        uint heirPercentage,
        uint heirPayoutOrder
    ) public onlyOwner {
        require(heirPayoutOrder > 0, "Payout order must be greater than 0");
        require(!heirs[heirAccount].isValid, "Heir already exists");
        require(heirsOrder[heirPayoutOrder] != address(0),
            "An heir already exists in that payout position."
        );
        require(
            remainingPercentage >= heirPercentage,
            "Adding this heir with selected percentage would exceed 100 percent"
        );

        remainingPercentage = remainingPercentage - heirPercentage;
        heirsOrder[heirPayoutOrder] = heirAccount;
        heirs[heirAccount]= Heir({
                                account: heirAccount,
                                percentage: 2,
                                payoutOrder: 3,
                                isValid: true
                            });
        amountHeirs++;
    }

    function removeHeir(address payable heirAccount) public onlyOwner {
        require(amountHeirs > 1, "Cannot remove the only heir");
        require(heirs[heirAccount].isValid, "this account is not an Heir");

        remainingPercentage = remainingPercentage + heirs[heirAccount].percentage;

        delete heirsOrder[heirs[heirAccount].payoutOrder];
        delete heirs[heirAccount];
    }

    function updateHeir(
        address payable heirAccount,
        uint heirPercentage,
        uint heirPayoutOrder
    ) public onlyOwner {
        require(heirPayoutOrder > 0, "Payout order must be greater than 0");
        require(heirs[heirAccount].isValid, "this account is not an Heir");

        uint heirPreviousPercentage = heirs[heirAccount].percentage;
        require(
            remainingPercentage + heirPreviousPercentage >= heirPercentage,
            "Updating this heir with selected percentage would exceed 100 percent"
        );

        uint heirPreviousOrder = heirs[heirAccount].percentage;
        
        require(heirsOrder[heirPayoutOrder] == heirAccount || heirsOrder[heirPayoutOrder] == address(0),
                    "An heir already exists in that payout position."
        );

        if (heirsOrder[heirPayoutOrder] == address(0)) {
            delete heirsOrder[heirPreviousOrder];
            heirsOrder[heirPayoutOrder] = heirAccount;
        }

        remainingPercentage += heirPreviousPercentage - heirPercentage;

        heirs[heirAccount].percentage = heirPercentage;
        heirs[heirAccount].payoutOrder = heirPayoutOrder;

    }

    function addManager(address payable managerAccount) public onlyOwner {
        require(amountManagers < 5, "You can't add a new manager");
        require(!managers[managerAccount].isValid,"This manager already exists");        
        Manager manager = new Manager(managerAccount, rules);
        address payable managerAddress = address(uint160(address(manager)));
        managers[managerAccount] = ManagerStruct({
            isValid: true,
            contractAccount: managerAddress,
            arrayKey: amountManagers
        });
        managerskeys[amountManagers] = managerAccount;
        amountManagers++;
    }

    function removeManager(address payable managerAccount) public onlyOwner {
        require(amountManagers > 2, "You can't remove a manager, a minimum of 2 is needed");
        require(managers[managerAccount].isValid, "Manager doesn't exist");
        Manager manager = Manager(managers[managerAccount].contractAccount);
        manager.destroy();
        uint managerKey = managers[managerAccount].arrayKey;
        if (managerKey < amountManagers - 1){ //Si la key está en el medio del arreglo hago swap con la última guardando la referencia en el map
            address lastManagerInArrayAddress = managerskeys[amountManagers - 1];
            managerskeys[managerKey] = lastManagerInArrayAddress;
            managers[lastManagerInArrayAddress].arrayKey = managerKey;
        }
        delete managers[managerAccount];
        amountManagers--;
    }

    function cancelContract() public onlyOwner {
        uint fee = (uint(cancellationPercentage) *
            uint(address(this).balance)) / uint(100);
        if (fee != uint(0)) {
            companyAddress.transfer(fee);
        }
        selfdestruct(owner.addresEth);
    }

    function withdrawFunds() public canManage{
        Manager manager = Manager(managers[msg.sender].contractAccount);
        require(!manager.hasActiveWithdrawal(), "This manager has already withdrawn funds");
        uint withdrawalTotal = (address(this).balance * withdrawalPercentageAllowed ) / 100;
        
        require(withdrawalTotal <= address(this).balance * managersPercentageFee / 100, "Withdrawal limit exceeded"); //Debe retirar menos del fee
        uint withdrawalFee = (rules.withdrawalPercentageFee() *  withdrawalTotal) / 100;
        manager.registerWithdraw(withdrawalTotal);
        companyAddress.transfer(withdrawalFee);
        msg.sender.transfer(withdrawalTotal - withdrawalFee);
    }

    function repayFunds() public onlyListedManagers payable {
        Manager manager = Manager(managers[msg.sender].contractAccount);
        require(manager.hasActiveWithdrawal(), "This manager has not active withdrwal");
        require(manager.canPay(), "Not enough founds to repay");
        manager.payWithdraw();
    }
    
    function activateContract() public isParticipant {
        uint daysSinceLastSignal = now - owner.lastSignal / 60 / 60 / 24;
        require(daysSinceLastSignal / 30 >= 6 || managersReportedOwnersDeath(), "No condition met to activate the contract");
    }
    
    function managersReportedOwnersDeath() private view returns (bool){
        bool managersReportedDeath = true;
        uint lastManagerReport = 0;
        for (uint i = 0; i < amountManagers - 1; i++){
            Manager manager = Manager(managers[managerskeys[i]].contractAccount);
            if (!manager.hasReportedOwnerDeath()){
                managersReportedDeath = false;
                break;
            } else {
                if (manager.reportedOwnerDeathDate() > lastManagerReport){
                    lastManagerReport = manager.reportedOwnerDeathDate();
                }
            }
        }
        return (managersReportedDeath && now - lastManagerReport /60 /60 /24 /30 >= 3);
    }
    
    function lifeSignal() public onlyOwner {
        owner.lastSignal = now;
        for (uint i = 0; i < amountManagers - 1; i++){
            Manager manager = Manager(managers[managerskeys[i]].contractAccount);
            manager.cleanOwnerDeathReport();
        }
    }
    
    function reportOwnersDeath() public canManage {
        Manager manager = Manager(managers[msg.sender].contractAccount);
        manager.reportOwnersDeath();
    }
}
