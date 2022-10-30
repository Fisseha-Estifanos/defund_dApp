// SPDX-License-Identifier: MIT
// Tells the Solidity compiler to compile only from v0.8.13 to v0.9.0
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

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
        //address employerAddress;
        address employeeAddress;
        uint256 contractDuration;
        uint256 contractStartDate;
        string employeeRole;
        ContractStatus contractStatus;
        uint256 balanceInWei;
        uint256 locLat;
        uint256 latOffset;
        uint256 locLon;
        uint256 lonOffset;
        uint256 acceptedRange;
    }

    // Employer data structure
    struct Employer {
        string name;
        address employer_address;
        string company;
    }

    // declare our state variables
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event NewEmployee(string name, address employeeAddress);

    Employer public employer;

    Employee[] public employees;

    uint256 public numberOfEmployeesCount;

    string public compDetailUpdateStatus;

    constructor() {
        // set the contract's owner (employer)
        employer = Employer("f0xtr0t", msg.sender, "Forward Operations Base");
        numberOfEmployeesCount = 0;
        compDetailUpdateStatus = "";
    }

    // A method to create employees
    function createEmployee(
        string memory name,
        address employeeAddress,
        uint256 contractDuration,
        string memory employeeRole,
        uint256 latitude,
        uint256 latitudeOffset,
        uint256 longitude,
        uint256 longOffset,
        uint256 acceptedRange
    ) public payable {
        // the contract starting date
        uint256 startDate = block.timestamp;

        // the contracts initial status
        ContractStatus initialContractStatus = ContractStatus.SIGNED;

        // get the current balance of the employee
        uint256 currentBalanceOfEmployee = getBalance(employeeAddress);

        employees.push(
            Employee(
                name,
                //msg.sender,
                employeeAddress,
                contractDuration,
                startDate,
                employeeRole,
                initialContractStatus,
                currentBalanceOfEmployee,
                latitude,
                latitudeOffset,
                longitude,
                longOffset,
                acceptedRange
            )
        );
        numberOfEmployeesCount++;
        emit NewEmployee(name, employeeAddress);
        //addToIPFS();
    }

    // A method to add employees to IPFS
    // function addEmployeeToIPFS() private view returns () {
    //     // add employee to IPFS
    // }

    // A method to get balance in wei
    function getBalance(address balanceAddress) public view returns (uint256) {
        return balanceAddress.balance;
    }

    // a function to get all employees
    function getAllEmployees() public view returns (Employee[] memory) {
        return (employees);
    }

    // a function to get the employer of this smart contract
    function getEmployer() public view returns (Employer memory) {
        return employer;
    }

    function editCompanyDetails(
        string memory name,
        address addr,
        string memory companyName
    ) public {
        if (msg.sender != employer.employer_address) {
            compDetailUpdateStatus = "This account can not update details";
            return;
        }
        employer = Employer(name, addr, companyName);
        compDetailUpdateStatus = "Company details updated";
    }
}
