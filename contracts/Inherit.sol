pragma solidity ^0.5.1;

import "./Rules.sol";
import "./Manager.sol";

contract Inherit {
    //DATA-STRUCTURES
    struct Person {
        uint256 ci;
        uint256 birthDate;
        string addressP;
        address payable addresEth;
        string phoneNumber;
        string email;
        uint256 hireDate;
        uint256 lastSignal;
    }

    struct Heir {
        bool isValid;
        bool isAlive;
        address payable account;
        uint256 percentage;
        uint256 payoutOrder;
    }

    struct ManagerStruct {
        bool isValid;
        address payable contractAccount;
        uint256 arrayKey;
    }

    //PROPERTIES

    Person public owner;

    uint256 public amountHeirs = 0;
    mapping(address => Heir) public heirs;
    mapping(uint256 => address) public heirsOrder;

    uint256 public amountManagers = 0;
    mapping(address => ManagerStruct) public managers; //KEY: Address externa
    address[5] private managerskeys;

    bool private amountInheritanceIsPublic = true;

    uint256 public lastAttemptToLiquidateByParticipants = 0;
    uint256 private remainingPercentage = 100;

    uint256 public cancellationPercentage; //Parametro en constructor
    uint256 public reductionPercentageFee; //Parametro en constructor
    uint256 public managersPercentageFee; //Parametro en constructor
    uint256 public withdrawalPercentageAllowed; //Parametro en constructor

    Rules private rules;
    address payable public companyAddress;

    //INITIALIZATION
    constructor(
        uint256 ci,
        uint256 birthDate,
        string memory addressP,
        string memory phoneNumber,
        string memory email,
        uint256 hireDate,
        uint256 _cancellationPercentage,
        uint256 _reductionPercentageFee,
        uint256 _managersPercentageFee,
        uint256 _withdrawalPercentageAllowed,
        address payable _companyAddress,
        address _rulesAddress
    ) public payable {
        rules = Rules(_rulesAddress);
        uint256 amtForTheCompany = rules.amountToPayUpfront();
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
        reductionPercentageFee = _reductionPercentageFee;
        companyAddress = _companyAddress;
        companyAddress.transfer(amtForTheCompany);
    }

    //FALLBACK FUNCTION
    function() external payable {}

    //GETTERS & SETTERS
    function amountInheritance() public view publicFiltered returns (uint256) {
        return
            address(this).balance -
            ((uint256(managersPercentageFee) *
                uint256(amountManagers) *
                uint256(address(this).balance)) / uint256(100));
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
        require(
            managers[msg.sender].isValid,
            "Only listed managers can execute this method"
        );
        _;
    }

    modifier canManage() {
        require(
            managers[msg.sender].isValid,
            "Only listed managers can execute this method"
        );
        Manager manager = Manager(managers[msg.sender].contractAccount);
        require(manager.canManage());
        _;
    }

    modifier isParticipant() {
        require(
            heirs[msg.sender].isValid || managers[msg.sender].isValid,
            "You need to be a participant"
        );
        if (managers[msg.sender].isValid) {
            Manager manager = Manager(managers[msg.sender].contractAccount);
            require(manager.canManage(), "You need to be a manager");
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
        uint256 heirPercentage,
        uint256 heirPayoutOrder
    ) public onlyOwner {
        require(heirPayoutOrder > 0, "Payout order must be greater than 0");
        require(!heirs[heirAccount].isValid, "Heir already exists");
        require(
            heirsOrder[heirPayoutOrder] != address(0),
            "An heir already exists in that payout position."
        );
        require(
            remainingPercentage >= heirPercentage,
            "Adding this heir with selected percentage would exceed 100 percent"
        );

        remainingPercentage = remainingPercentage - heirPercentage;
        heirsOrder[heirPayoutOrder] = heirAccount;
        heirs[heirAccount] = Heir({
            account: heirAccount,
            percentage: 2,
            payoutOrder: 3,
            isValid: true,
            isAlive: true
        });
        amountHeirs++;
    }

    function removeHeir(address payable heirAccount) public onlyOwner {
        require(amountHeirs > 1, "Cannot remove the only heir");
        require(heirs[heirAccount].isValid, "this account is not an Heir");

        remainingPercentage =
            remainingPercentage +
            heirs[heirAccount].percentage;

        delete heirsOrder[heirs[heirAccount].payoutOrder];
        delete heirs[heirAccount];
    }

    function updateHeir(
        address payable heirAccount,
        uint256 heirPercentage,
        uint256 heirPayoutOrder
    ) public onlyOwner {
        require(heirPayoutOrder > 0, "Payout order must be greater than 0");
        require(heirs[heirAccount].isValid, "this account is not an Heir");

        uint256 heirPreviousPercentage = heirs[heirAccount].percentage;
        require(
            remainingPercentage + heirPreviousPercentage >= heirPercentage,
            "Updating this heir with selected percentage would exceed 100 percent"
        );

        uint256 heirPreviousOrder = heirs[heirAccount].percentage;

        require(
            heirsOrder[heirPayoutOrder] == heirAccount ||
                heirsOrder[heirPayoutOrder] == address(0),
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
        require(
            !managers[managerAccount].isValid,
            "This manager already exists"
        );
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
        require(
            amountManagers > 2,
            "You can't remove a manager, a minimum of 2 is needed"
        );
        require(managers[managerAccount].isValid, "Manager doesn't exist");
        Manager manager = Manager(managers[managerAccount].contractAccount);
        manager.destroy();
        uint256 managerKey = managers[managerAccount].arrayKey;
        if (managerKey < amountManagers - 1) {
            //Si la key está en el medio del arreglo hago swap con la última guardando la referencia en el map
            address lastManagerInArrayAddress = managerskeys[amountManagers -
                1];
            managerskeys[managerKey] = lastManagerInArrayAddress;
            managers[lastManagerInArrayAddress].arrayKey = managerKey;
        }
        delete managers[managerAccount];
        amountManagers--;
    }

    function cancelContract() public onlyOwner {
        uint256 fee = (uint256(cancellationPercentage) *
            uint256(address(this).balance)) / uint256(100);
        if (fee != uint256(0)) {
            companyAddress.transfer(fee);
        }
        selfdestruct(owner.addresEth);
    }

    function withdrawFunds(string memory _reason) public canManage {
        Manager manager = Manager(managers[msg.sender].contractAccount);
        require(
            !manager.hasActiveWithdrawal(),
            "This manager has already withdrawn funds"
        );
        uint256 withdrawalTotal = (address(this).balance *
            withdrawalPercentageAllowed) / 100;

        require(
            withdrawalTotal <=
                (address(this).balance * managersPercentageFee) / 100,
            "Withdrawal limit exceeded"
        ); //Debe retirar menos del fee
        uint256 withdrawalFee = (rules.withdrawalPercentageFee() *
            withdrawalTotal) / 100;
        manager.registerWithdraw(_reason, withdrawalTotal);
        companyAddress.transfer(withdrawalFee);
        msg.sender.transfer(withdrawalTotal - withdrawalFee);
    }

    function repayFunds() public payable onlyListedManagers {
        Manager manager = Manager(managers[msg.sender].contractAccount);
        require(
            manager.hasActiveWithdrawal(),
            "This manager has not active withdrwal"
        );
        require(manager.canPay(), "Not enough founds to repay");
        manager.payWithdraw();
    }

    function managersReportedOwnersDeath() private view returns (bool) {
        bool managersReportedDeath = true;
        uint256 lastManagerReport = 0;
        for (uint256 i = 0; i < amountManagers - 1; i++) {
            Manager manager = Manager(
                managers[managerskeys[i]].contractAccount
            );
            if (!manager.hasReportedOwnerDeath()) {
                managersReportedDeath = false;
                break;
            } else {
                if (manager.reportedOwnerDeathDate() > lastManagerReport) {
                    lastManagerReport = manager.reportedOwnerDeathDate();
                }
            }
        }
        return (managersReportedDeath &&
            now - lastManagerReport / 60 / 60 / 24 / 30 >= 3);
    }

    function lifeSignal() public onlyOwner {
        owner.lastSignal = now;
        for (uint256 i = 0; i < amountManagers - 1; i++) {
            Manager manager = Manager(
                managers[managerskeys[i]].contractAccount
            );
            manager.cleanOwnerDeathReport();
        }
    }

    function reportOwnersDeath() public canManage {
        Manager manager = Manager(managers[msg.sender].contractAccount);
        manager.reportOwnersDeath();
    }

    function reportDeadHeir(address heirAccount) public canManage {
        require(heirs[heirAccount].isValid, "this account is not an heir");

        heirs[heirAccount].isAlive = false;
        delete heirsOrder[heirs[heirAccount].payoutOrder];
    }

    function activateContract() public isParticipant {
        lastAttemptToLiquidateByParticipants = now;
        require(
            monthsSinceOwnerLastSignal() >= 6 || managersReportedOwnersDeath(),
            "No condition met to activate the contract"
        );

        uint256 balance = address(this).balance;
        address payable lastHeirAddress = companyAddress;
        // heirs
        for (uint256 i = 0; i < amountHeirs; i++) {
            Heir memory heir = heirs[heirsOrder[i]];
            if (heir.isValid && heir.isAlive) {
                uint256 toPay = (heir.percentage * balance) / uint256(100);

                if (!heir.account.send(toPay)) {
                    if (i == 0) {
                        heirs[heirsOrder[1]].account.send(toPay);
                        lastHeirAddress = heirs[heirsOrder[1]].account;
                    }
                    lastHeirAddress.send(toPay);
                    continue;
                }
                lastHeirAddress = heirs[heirsOrder[i]].account;
            }
        }

        uint256 managersAmount = (balance * managersPercentageFee) / 100;
        // managers
        for (uint256 i = 0; i < amountManagers; i++) {
            Manager manager = Manager(
                managers[managerskeys[i]].contractAccount
            );

            uint wdr = manager.withdrawalAmount();
            if (managersAmount > wdr) {
                address payable mAddress = address(uint160(managerskeys[i]));
                mAddress.send(managersAmount - wdr);
            }

            manager.destroy();
        }

        selfdestruct(companyAddress);
    }

    function attemptToLiquidateContract() public {
        require(
            msg.sender == companyAddress,
            "You need to be a part of the company to do this"
        );
        require(
            monthsSinceOwnerLastSignal() >= 36 &&
                timeStampToDays(now - lastAttemptToLiquidateByParticipants) /
                    30 >=
                36,
            "36 months need to pass first."
        );

        selfdestruct(companyAddress);
    }

    function timeStampToDays(uint256 timeStamp) private pure returns (uint256) {
        return timeStamp / 60 / 60 / 24;
    }

    function daysSinceOwnerLastSignal() private view returns (uint256) {
        return timeStampToDays(now - owner.lastSignal);
    }

    function monthsSinceOwnerLastSignal() private view returns (uint256) {
        return daysSinceOwnerLastSignal() / 30;
    }

    function reduceInheritanceAmount(uint amountToReduce) public onlyOwner {
        require( amountToReduce < amountInheritance(), "You cant reduce that much money");
        uint reductionFee = amountInheritance() * reductionPercentageFee / 100;
        address(owner.addresEth).transfer(amountToReduce);
        address(companyAddress).transfer(reductionFee);
    }
}
