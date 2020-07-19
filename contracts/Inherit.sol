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
    }

    //PROPERTIES

    Person public owner;

    uint public amountHeirs = 0;
    mapping(address => Heir) public heirs;
    mapping(uint => address) public heirsOrder;

    uint public amountManagers = 0;
    mapping(address => ManagerStruct) public managers; //KEY: Address externa

    bool private amountInheritanceIsPublic = true;

    uint private remainingPercentage = 100;

    uint public cancellationPercentage = 2; //Parametro en constructor
    uint public managersPercentageFee = 5; //Parametro en constructor
    uint public withdrawalPercentageAllowed = 1; //Parametro en constructor

    //COMING FROM OUTSIDE
    address payable public companyAddress;
    uint public withdrawalPercentageFee = 1; // Fee definido en las reglas
    uint public withdrawalPenaltyPercentageFeeByDay = 1;
    uint public withdrawalPenaltyMaxDays = 30;

    //INITIALIZATION
    constructor(
        uint ci,
        uint birthDate,
        string memory addressP,
        string memory phoneNumber,
        string memory email,
        uint hireDate,
        address payable _companyAddress
    ) public payable {
        Rules r = new Rules();
        uint amtForTheCompany = r.amountToPayUpfront();
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
            email: email
        });

        cancellationPercentage = 2;

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

    modifier publicFiltered() { 
        // if (!amountInheritanceIsPublic) {
        //     bool isHeir = false;
        //     for (uint j = 0; j < heirs.length; j++) {
        //         if (heirs[j].account == msg.sender) {
        //             isHeir = true;
        //             break;
        //         }
        //     }
        //     require(
        //         isHeir || msg.sender == owner.addresEth,
        //         "Only the owner or an heir can execute this method"
        //     );
        // }
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
        Manager manager = new Manager(managerAccount);
        address payable managerAddress = address(uint160(address(manager)));
        managers[managerAccount] = ManagerStruct({
            isValid: true,
            contractAccount: managerAddress
        });
        amountManagers++;
    }

    function removeManager(address payable managerAccount) public onlyOwner {
        require(amountManagers > 2, "You can't remove a manager, a minimum of 2 is needed");
        require(managers[managerAccount].isValid, "Manager doesn't exist");
        Manager manager = Manager(managers[managerAccount].contractAccount);
        manager.destroy();
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
        uint withdrawalFee = (withdrawalPercentageFee *  withdrawalTotal) / 100;
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

}
