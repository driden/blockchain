pragma solidity ^0.5.1;

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
        address payable account;
        uint percentage;
        uint payoutOrder;
    }

    struct Manager {
        address payable account;
        uint percentage;
    }

    //PROPERTIES
    Person public owner ;

    uint public amountHeirs = 0;
    Heir[] public heirs;

    uint public amountManagers = 0;
    Manager[5] public managers;

    bool private amountInheritanceIsPublic = true;

    uint private remainingPercentage = 100;

    uint public cancellationPercentage = 2; //Parametro en constructor
        //COMING FROM OUTSIDE
        address payable public companyAddress = 0x9084dc54eD39303124cf68c6535F68372c471675;
        uint public dollarToWeiRate = 4242802476308100;
        uint public managersPercentage = 5;

    //INITIALIZATION
    constructor() public payable {
        require(address(this).balance > dollarToWeiRate * uint(200), "Not enough funds to instance the contract.");
        companyAddress.transfer(dollarToWeiRate * uint(200));

        owner = Person ({
            ci : 1111111,
            birthDate : 58973597823795938757982,
            hireDate : 98973597823795938757982,
            addressP : "jfasfksdkljflkasjf",
            addresEth: msg.sender,
            phoneNumber : "phone",
            email : "email"
        });
        addHeir(
          0xFb383f301805D65e860b58B11d2728bbB945A793,
          1,
          1
        );
        addManager(0xE05D1C8329304382903c9F72b8dbCBC6CF444Fb9);
        addManager(0xEFad154ABBc4Af7198E99B65aAD14ef9EDd10365);
        companyAddress = 0x9084dc54eD39303124cf68c6535F68372c471675;
        cancellationPercentage = 2;
    }

    function () external payable {
    }

    //GETTERS & SETTERS
    function amountInheritance() publicFiltered public view returns (uint) {
        return address(this).balance - (uint(managersPercentage)* uint(amountManagers) * uint(address(this).balance)/uint(100));
    }

    function setAmountInheritanceVisibility(bool isVisible) onlyOwner public{
        amountInheritanceIsPublic = isVisible;
    }

    //MODIFIERS
    modifier onlyOwner() {
        require(msg.sender == owner.addresEth, "Only the owner can execute this method");
        _;
    }

    modifier publicFiltered(){
        if(!amountInheritanceIsPublic){
            bool isHeir = false;
            for (uint j = 0; j < heirs.length; j++) {
                if (heirs[j].account == msg.sender){
                    isHeir = true;
                    break;
                }
            }
            require(isHeir || msg.sender == owner.addresEth, "Only the owner or an heir can execute this method");
        }
        _;
    }

    //FUNCTIONS
    function addHeir (address payable heirAccount, uint heirPercentage, uint heirPayoutOrder) onlyOwner public{
        require(heirPayoutOrder > 0, "Payout order must be greater than 0");
        uint length = heirs.length;
        for (uint j = 0; j < length; j++) {
            require(heirs[j].account != heirAccount, "Heir already exists");
            require(heirs[j].payoutOrder != heirPayoutOrder, "An heir already exists in that payout position.");
        }

        require(remainingPercentage >= heirPercentage, "Adding this heir with selected percentage would exceed 100 percent");
        remainingPercentage = remainingPercentage - heirPercentage;
        heirs.push(Heir({account: heirAccount, percentage:heirPercentage, payoutOrder: heirPayoutOrder}));
        amountHeirs++;
    }

    function removeHeir(address payable heirAccount) onlyOwner public {
        require(heirs.length > 1, "Cannot remove the only heir");
        for (uint j = 0; j < heirs.length; j++) {
            if (heirs[j].account == heirAccount){
                remainingPercentage = remainingPercentage + heirs[j].percentage;
                delete heirs[j];
                heirs[j] = heirs[heirs.length - 1];
                heirs.length--;
            }
        }
    }

    function addManager (address payable managerAccount) onlyOwner public {
        require(amountManagers < 5, "You can't add a new manager");
        for(uint i = 0; i < amountManagers; i++) {
            require(managers[i].account != managerAccount, "This manager already exists");
        }
        require(remainingPercentage >= managersPercentage, "Adding this manager with selected percentage would exceed 100 percent");
        remainingPercentage = remainingPercentage - managersPercentage;
        managers[amountManagers] = Manager({
            account : managerAccount,
            percentage: managersPercentage
        });
        amountManagers++;
    }

    function removeManager(address payable managerAccount) onlyOwner public {
        require(amountManagers > 2, "You can't remove a manager right now, a minimum of 2 is needed");
        for (uint j = 0; j < managers.length; j++) {
            if (managers[j].account == managerAccount){
                remainingPercentage = remainingPercentage + managers[j].percentage;
                delete managers[j];
                managers[j] = managers[amountManagers - 1];
                amountManagers--;
            }
        }
    }

    function cancelContract() onlyOwner public {
        uint fee = (uint(cancellationPercentage)*uint(address(this).balance))/uint(100);
        if (fee != uint(0)){
            companyAddress.transfer(fee);
        }
        selfdestruct(owner.addresEth);
    }

    function upsertHeir(address payable heirAccount, uint heirPercentage, uint heirPayoutOrder) onlyOwner public{
        require(heirPayoutOrder > 0, "Payout order must be greater than 0");
        uint length = heirs.length;
        uint heirPreviousPercentage = 0;
        uint heirIndex = heirs.length;
        for (uint j = 0; j < length; j++) {
            if (heirs[j].account == heirAccount){
                heirIndex = j;
                heirPreviousPercentage = heirs[j].percentage;
            } else {
                require(heirs[j].payoutOrder != heirPayoutOrder, "An heir already exists in that payout position.");
            }
        }
        require(remainingPercentage + heirPreviousPercentage >= heirPercentage, "Updating this heir with selected percentage would exceed 100 percent");
        remainingPercentage = remainingPercentage + heirPreviousPercentage - heirPercentage;
        if (heirIndex == heirs.length){ //Si el heredero no existe para hacer upsert
            heirs.push(Heir({account: heirAccount, percentage:heirPercentage, payoutOrder: heirPayoutOrder}));
        } else {
            heirs[heirIndex].percentage = heirPercentage;
            heirs[heirIndex].payoutOrder = heirPayoutOrder;
        }
    }
}