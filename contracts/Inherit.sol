pragma solidity ^0.5.1;

import "./Rules.sol";

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
    }

    struct Heir {
        address payable account;
        uint256 percentage;
        uint256 payoutOrder;
    }

    struct Manager {
        address payable account;
        uint256 percentage;
        bool canManage;
        uint256 withdrawalTimestamp;
        uint256 widhrawalAmount;
    }

    //PROPERTIES
    Person public owner;

    uint256 public amountHeirs = 0;
    Heir[] public heirs;

    uint256 public amountManagers = 0;
    Manager[5] public managers;

    bool private amountInheritanceIsPublic = true;

    uint256 private remainingPercentage = 100;

    uint256 public cancellationPercentage = 2; //Parametro en constructor
    uint256 private canWithdraw = 5; // Parametro en el constructor, los managers pueden sacar un prestamo del 15% del contrato

    //COMING FROM OUTSIDE
    address payable public companyAddress;

    uint256 public managersPercentage = 5;
    uint256 private withdrawalPercentageFee = 1; // en las reglas, porcentaje del porcentaje especificado por owner

    //INITIALIZATION
    constructor(
        uint256 ci,
        uint256 birthDate,
        string memory addressP,
        string memory phoneNumber,
        string memory email,
        uint256 hireDate,
        address payable _companyAddress
    ) public payable {
        Rules r = new Rules();
        uint256 amtForTheCompany = r.amountToPayUpfront();
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

    function() external payable {}

    //GETTERS & SETTERS
    function amountInheritance() public view publicFiltered returns (uint256) {
        return
            address(this).balance -
            ((uint256(managersPercentage) *
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

    modifier canManage() {
        for (uint256 i = 0; i < amountManagers; i++) {
            if (msg.sender == managers[i].account) {
                require(
                    managers[i].canManage,
                    "this account is not authorized"
                );
            }
        }
        _;
    }

    modifier publicFiltered() {
        if (!amountInheritanceIsPublic) {
            bool isHeir = false;
            for (uint256 j = 0; j < heirs.length; j++) {
                if (heirs[j].account == msg.sender) {
                    isHeir = true;
                    break;
                }
            }
            require(
                isHeir || msg.sender == owner.addresEth,
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
        uint256 length = heirs.length;
        for (uint256 j = 0; j < length; j++) {
            require(heirs[j].account != heirAccount, "Heir already exists");
            require(
                heirs[j].payoutOrder != heirPayoutOrder,
                "An heir already exists in that payout position."
            );
        }

        require(
            remainingPercentage >= heirPercentage,
            "Adding this heir with selected percentage would exceed 100 percent"
        );
        remainingPercentage = remainingPercentage - heirPercentage;
        heirs.push(
            Heir({
                account: heirAccount,
                percentage: heirPercentage,
                payoutOrder: heirPayoutOrder
            })
        );
        amountHeirs++;
    }

    function removeHeir(address payable heirAccount) public onlyOwner {
        require(heirs.length > 1, "Cannot remove the only heir");
        for (uint256 j = 0; j < heirs.length; j++) {
            if (heirs[j].account == heirAccount) {
                remainingPercentage = remainingPercentage + heirs[j].percentage;
                delete heirs[j];
                heirs[j] = heirs[heirs.length - 1];
                heirs.length--;
            }
        }
    }

    function addManager(address payable managerAccount) public onlyOwner {
        require(amountManagers < 5, "You can't add a new manager");
        for (uint256 i = 0; i < amountManagers; i++) {
            require(
                managers[i].account != managerAccount,
                "This manager already exists"
            );
        }
        require(
            remainingPercentage >= managersPercentage,
            "Adding this manager with selected percentage would exceed 100 percent"
        );
        remainingPercentage = remainingPercentage - managersPercentage;
        managers[amountManagers] = Manager({
            account: managerAccount,
            percentage: managersPercentage,
            canManage: true,
            withdrawalTimestamp: 0,
            widhrawalAmount: 0
        });
        amountManagers++;
    }

    function removeManager(address payable managerAccount) public onlyOwner {
        require(
            amountManagers > 2,
            "You can't remove a manager right now, a minimum of 2 is needed"
        );
        for (uint256 j = 0; j < managers.length; j++) {
            if (managers[j].account == managerAccount) {
                remainingPercentage =
                    remainingPercentage +
                    managers[j].percentage;
                delete managers[j];
                managers[j] = managers[amountManagers - 1];
                amountManagers--;
            }
        }
    }

    function cancelContract() public onlyOwner {
        uint256 fee = (uint256(cancellationPercentage) *
            uint256(address(this).balance)) / uint256(100);
        if (fee != uint256(0)) {
            companyAddress.transfer(fee);
        }
        selfdestruct(owner.addresEth);
    }

    function upsertHeir(
        address payable heirAccount,
        uint256 heirPercentage,
        uint256 heirPayoutOrder
    ) public onlyOwner {
        require(heirPayoutOrder > 0, "Payout order must be greater than 0");
        uint256 length = heirs.length;
        uint256 heirPreviousPercentage = 0;
        uint256 heirIndex = heirs.length;
        for (uint256 j = 0; j < length; j++) {
            if (heirs[j].account == heirAccount) {
                heirIndex = j;
                heirPreviousPercentage = heirs[j].percentage;
            } else {
                require(
                    heirs[j].payoutOrder != heirPayoutOrder,
                    "An heir already exists in that payout position."
                );
            }
        }
        require(
            remainingPercentage + heirPreviousPercentage >= heirPercentage,
            "Updating this heir with selected percentage would exceed 100 percent"
        );
        remainingPercentage =
            remainingPercentage +
            heirPreviousPercentage -
            heirPercentage;
        if (heirIndex == heirs.length) {
            //Si el heredero no existe para hacer upsert
            heirs.push(
                Heir({
                    account: heirAccount,
                    percentage: heirPercentage,
                    payoutOrder: heirPayoutOrder
                })
            );
        } else {
            heirs[heirIndex].percentage = heirPercentage;
            heirs[heirIndex].payoutOrder = heirPayoutOrder;
        }
    }

    // se dispara un evento cuando pase esto?
    function withdrawPercentage() public canManage {
        for (uint256 i = 0; i < amountManagers; i++) {
            if (managers[i].account == msg.sender) {
                uint256 withdrawalTotal = (address(this).balance *
                    withdrawalPercentageFee) / 100;
                uint256 withdrawalFee = (withdrawalPercentageFee *
                    withdrawalTotal) / 100;

                managers[i].withdrawalTimestamp = block.timestamp;
                managers[i].widhrawalAmount = withdrawalTotal;
                companyAddress.transfer(withdrawalFee);
                managers[i].account.transfer(withdrawalTotal - withdrawalFee);
            }
        }
    }
}
