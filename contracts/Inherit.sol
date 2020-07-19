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
        bool canManage;
        uint withdrawalTimestamp;
        uint widhrawalAmount;
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
    uint private canWithdraw = 5; // Parametro en el constructor, los managers pueden sacar un prestamo del 15% del contrato

        //COMING FROM OUTSIDE
        address payable public companyAddress = 0x9084dc54eD39303124cf68c6535F68372c471675;
        uint public dollarToWeiRate = 4242802476308100;
        uint public managersPercentage = 5;
        uint private withdrawalPercentageFee = 1; // en las reglas, porcentaje del porcentaje especificado por owner

    //INITIALIZATION
    constructor() public payable {
        require(address(this).balance > dollarToWeiRate * uint(200), "Not enough funds to instance the contract.");

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
          0x3cdD4c51f7f0ceb8A4eeC0bF979fF260A7F05F0B,
          1,
          1
        );
        addManager(0x3155590fCA8867c0adCFDEe9c7b314408b290571);
        addManager(0x5e41814b7A7ab6afcE148E9D0ae8D79e88259Fcf);
        companyAddress = 0x6E4De761bf9d23f96888053D4C2d8199fEbC1023;
        cancellationPercentage = 2;
        companyAddress.transfer(dollarToWeiRate * uint(200));
    }

    function () external payable {
    }

    //GETTERS & SETTERS
    function amountInheritance() public publicFiltered view   returns (uint) {
        return address(this).balance - (uint(managersPercentage) * uint(amountManagers) * uint(address(this).balance)/uint(100));
    }

    function setAmountInheritanceVisibility(bool isVisible) public onlyOwner {
        amountInheritanceIsPublic = isVisible;
    }

    //MODIFIERS
    modifier onlyOwner() {
        require(msg.sender == owner.addresEth, "Only the owner can execute this method");
        _;
    }

    modifier canManage(){
        for(uint i = 0; i < amountManagers; i++){
            if (msg.sender == managers[i].account){
                require(managers[i].canManage, "this account is not authorized");
            }
        }
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
    function addHeir (address payable heirAccount, uint heirPercentage, uint heirPayoutOrder) public onlyOwner {
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

    function removeHeir(address payable heirAccount) public  onlyOwner  {
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

    function addManager (address payable managerAccount) public onlyOwner  {
        require(amountManagers < 5, "You can't add a new manager");
        for(uint i = 0; i < amountManagers; i++) {
            require(managers[i].account != managerAccount, "This manager already exists");
        }
        require(remainingPercentage >= managersPercentage, "Adding this manager with selected percentage would exceed 100 percent");
        remainingPercentage = remainingPercentage - managersPercentage;
        managers[amountManagers] = Manager({
            account : managerAccount,
            percentage: managersPercentage,
            canManage:true,
            withdrawalTimestamp:0,
            widhrawalAmount:0
        });
        amountManagers++;
    }

    function removeManager(address payable managerAccount) public onlyOwner {
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

    function cancelContract() public onlyOwner {
        uint fee = (uint(cancellationPercentage)*uint(address(this).balance))/uint(100);
        if (fee != uint(0)){
            companyAddress.transfer(fee);
        }
        selfdestruct(owner.addresEth);
    }

    function upsertHeir(address payable heirAccount, uint heirPercentage, uint heirPayoutOrder) public onlyOwner {
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
        require(remainingPercentage + heirPreviousPercentage >= heirPercentage,
            "Updating this heir with selected percentage would exceed 100 percent");
        remainingPercentage = remainingPercentage + heirPreviousPercentage - heirPercentage;
        if (heirIndex == heirs.length){ //Si el heredero no existe para hacer upsert
            heirs.push(Heir({account: heirAccount, percentage:heirPercentage, payoutOrder: heirPayoutOrder}));
        } else {
            heirs[heirIndex].percentage = heirPercentage;
            heirs[heirIndex].payoutOrder = heirPayoutOrder;
        }
    }

    // se dispara un evento cuando pase esto?
    function withdrawPercentage() public canManage  {
        for (uint i = 0; i < amountManagers; i++){
            if (managers[i].account == msg.sender){

                uint withdrawalTotal = address(this).balance * withdrawalPercentageFee / 100;
                uint withdrawalFee = withdrawalPercentageFee * withdrawalTotal / 100;

                managers[i].withdrawalTimestamp = block.timestamp;
                managers[i].widhrawalAmount = withdrawalTotal;
                companyAddress.transfer(withdrawalFee);
                managers[i].account.transfer(withdrawalTotal - withdrawalFee);
            }
        }
    }
}