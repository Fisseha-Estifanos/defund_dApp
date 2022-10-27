// SPDX-License-Identifier: MIT
// Tells the Solidity compiler to compile only from v0.8.13 to v0.9.0
pragma solidity ^0.8.13;

contract Refund {
    // several contract states
    enum ContractStatus {
        SIGNED,
        COMPLETED,
        REJECTED,
        ENDED
    }

    // Employee data structure
    struct Employee {
        string name;
        address employerAddress;
        address employeeAddress;
        uint256 contractDuration;
        uint256 contractStartDate;
        string employeeRole;
        ContractStatus contractStatus;
        uint256 balanceInWei;
    }

    // Employer data structure
    struct Employer {
        string name;
        string company;
        address employer_address;
    }

    // declare our state variables
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event NewEmployee(string name, address employeeAddress);
    Employer private employer;
    Employee[] private employees;

    constructor (){
        // set the contract's owner (employer)
        employer = Employer("f0x - tr0t", "FOB", msg.sender);
    }

    // A method to create employees
    function createEmployee(string memory name, address employeeAddress, uint256 contractDuration, string memory employeeRole) public {
        // the contract starting date
        uint256 startDate = block.timestamp;

        // the contracts initial status
        ContractStatus initialContractStatus = ContractStatus.SIGNED;

        // get the current balance of the employee
        uint256 currentBalanceOfEmployee = getBalance(employeeAddress);

        employees.push(Employee(name, msg.sender, employeeAddress, contractDuration, startDate, employeeRole, initialContractStatus, currentBalanceOfEmployee));
        emit NewEmployee(name, employeeAddress);
    }

    // A method to get balance in wei
    function getBalance(address balanceAddress) public view returns (uint256) {
        return balanceAddress.balance;
    }

    // a function to get all employees
    function getAllEmployees() public view returns (Employee[] memory) { 
        return employees;
    }

     // a function to get the employer of this smart contract
    function getEmployer() public view returns (Employer memory) { 
        return employer;
    }
}
