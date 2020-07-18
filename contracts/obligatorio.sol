pragma solidity ^0.5.1;

contract Inherit {
    struct Person {
        uint256 ci;
        uint birthDate;
        string addressP;
        string phoneNumber;
        string email;
        uint hireDate;
    }
    
    struct Heir {
        address payable account;
        uint8 percentage;
        uint payoutOrder;
    }
    
    uint public amountInheritance = address(this).balance;
    
    uint public amountHeirs = 0;
    Heir[] public heirs;
    
    uint8 public amountInCharge = 0;
    address[5] public managers;
    
    Person public owner ;
    
    //Debe recibir owner, un heredero y dos managers.
    constructor() public payable {
        owner = Person ({
            ci : 1111111,
            birthDate : 58973597823795938757982,
            hireDate : 98973597823795938757982,
            addressP : "jfasfksdkljflkasjf",
            phoneNumber : "phone",
            email : "email"
        });
        heirs.push(Heir({
          account: 0x7ac305928C723d7D4C8A612A80372f5316Ff3aE6,
          percentage: 1,
          payoutOrder: 1
        }));
        managers[0] = 0x5e41814b7A7ab6afcE148E9D0ae8D79e88259Fcf;
        managers[1] = 0x3155590fCA8867c0adCFDEe9c7b314408b290571;
    }
    
    //Cada heredero debe ser designado con el porcentaje que debe recibir de herencia
    function addHeir (address payable heirAccount, uint8 heirPercentage, uint heirPayoutOrder) public{
        require(heirPayoutOrder > 0, "Payout order must be greater than 0");
        uint percentage = 0;
        uint length = heirs.length;
        for (uint j = 0; j < length; j++) {
            require(heirs[j].account != heirAccount, "Heir already exists");
            require(heirs[j].payoutOrder != heirPayoutOrder, "An heir already exists in that payout position.");
            percentage += heirs[j].percentage;
        }
        
        require(percentage + heirPercentage <= 100, "Adding this heir with percentage would exceed 100 percent");
        heirs.push(Heir({account: heirAccount, percentage:heirPercentage, payoutOrder: heirPayoutOrder}));
        amountHeirs++;
    }
    
    function removeHeir(address payable heirAccount) public {
        
        require(heirs.length > 1, "Cannot remove the only heir");
        for (uint j = 0; j < heirs.length; j++) {
            if (heirs[j].account == heirAccount){
                delete heirs[j];
                heirs[j] = heirs[heirs.length - 1];
                heirs.length--;
            }
            
        }
    }
}