// SPDX-License-Identifier: MIT
// Tells the Solidity compiler to compile only from v0.8.13 to v0.9.0
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

contract Refund {
    // several contract states
    enum ContractStatus {
        SIGNED,
        ACTIVATED,
        REJECTED,
        ENDED
    }

    // Employee data structure
    struct Employee {
        string name;
        address payable employeeAddress;
        uint256 contractDuration;
        uint256 contractStartDate;
        string employeeRole;
        ContractStatus contractStatus;
        uint256 balanceInWei;
        int256 locLat;
        uint256 latOffset;
        int256 locLon;
        uint256 lonOffset;
        int256 acceptedRange;
        // TODO: add employee salary
    }

    // Employer data structure
    struct Employer {
        string name;
        address employer_address;
        string company;
    }

    // Employer location tracker structure
    struct Locations {
        string name;
        address employeeAddress;
        int256 locLat;
        uint256 latOffset;
        int256 locLon;
        uint256 lonOffset;
        uint256 locationUpdateDate;
    }

    // declare our state variables
    event EmployeeAdded(string name, address employeeAddress);
    event LocationTracked(string name, address employeeAddress, uint256 date);

    Employer public employer;

    Employee[] public employees;
    Locations[] public locations;
    mapping(address => Employee) public employeez;
    mapping(uint256 => address) public employeesAddress;

    uint256 public numberOfEmployeesCount;
    uint256 public numberOfTrackedLocations;

    string public compDetailUpdateStatus;

    constructor() payable {
        // set the contract's owner (employer)
        employer = Employer("f0xtr0t", msg.sender, "Forward Operations Base");

        numberOfEmployeesCount = 0;
        numberOfTrackedLocations = 0;
        compDetailUpdateStatus = "";
    }

    // a method to edit company details
    function editCompanyDetails(
        string memory name,
        address payable addr,
        string memory companyName
    ) public {
        if (msg.sender != employer.employer_address) {
            compDetailUpdateStatus = "This account can not update details";
            return;
        }
        employer = Employer(name, addr, companyName);
        compDetailUpdateStatus = "Company details updated";
    }

    // a method to create employees
    function createEmployee(
        string memory name,
        address payable employeeAddress,
        uint256 contractDuration,
        string memory employeeRole,
        int256 latitude,
        uint256 latitudeOffset,
        int256 longitude,
        uint256 longOffset,
        int256 acceptedRange // ) public payable {
    ) public {
        // the contract starting date
        uint256 startDate = block.timestamp;

        // the contracts initial status
        ContractStatus initialContractStatus = ContractStatus.SIGNED;

        // get the current balance of the employee
        uint256 currentBalanceOfEmployee = getBalance(employeeAddress);

        employees.push(
            Employee(
                name,
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

        employeez[employeeAddress] = Employee(
            name,
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
        );
        employeesAddress[numberOfEmployeesCount] = employeeAddress;
        numberOfEmployeesCount++;
        emit EmployeeAdded(name, employeeAddress);
    }

    // a method that calculates square root
    function sqrt(int256 x) private pure returns (int256 y) {
        int256 z = (x + 1) / 2;
        y = x;
        while (z < (y)) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }

    // a method to get the distance between two points
    function getDistance(
        int256 lat,
        int256 lng,
        int256 lat1,
        int256 lng1
    ) private pure returns (int256) {
        int256 dist = sqrt(((lat - lat1)**2) + ((lng - lng1)**2));
        return dist;
    }

    // a method to check employee distance range
    function checkEmployeeRange(
        address employee_address,
        int256 lat,
        int256 lon
    ) private {
        // Get the employee
        Employee memory employee = employeez[employee_address];

        // get the distance between the current location and the agreed location
        int256 currentRange = getDistance(
            lat,
            lon,
            employee.locLat,
            employee.locLon
        );

        if (currentRange > employee.acceptedRange) {
            // fail the contracts state
            employee.contractStatus = ContractStatus.REJECTED;
        } else {
            // activate the contract status
            employee.contractStatus = ContractStatus.ACTIVATED;
        }
        employeez[msg.sender] = employee;
    }

    // a method to track employee location
    function trackLocation(
        int256 latitude,
        uint256 latitudeOffset,
        int256 longitude,
        uint256 longOffset // ) public payable {
    ) public {
        // the location track date
        uint256 locationUpdatedAt = block.timestamp;

        // get the employee
        Employee memory current_employee = employeez[msg.sender];

        locations.push(
            Locations(
                current_employee.name,
                msg.sender,
                latitude,
                latitudeOffset,
                longitude,
                longOffset,
                locationUpdatedAt
            )
        );

        numberOfTrackedLocations++;
        emit LocationTracked(
            current_employee.name,
            msg.sender,
            locationUpdatedAt
        );

        checkEmployeeRange(msg.sender, latitude, longitude);
    }

    // a method to get balance in wei
    function getBalance(address balanceAddress) public view returns (uint256) {
        // if you want to return this smart contracts balance
        // this refers to this smart contract address and and you can cast it to address
        // in order to use the .balance functionality
        // return address(this).balance;
        return balanceAddress.balance;
    }

    // a method to get all employees
    function getAllEmployeez() public view returns (Employee[] memory) {
        Employee[] memory ret = new Employee[](numberOfEmployeesCount);
        for (uint256 i = 0; i < numberOfEmployeesCount; i++) {
            ret[i] = employeez[employeesAddress[i]];
        }
        return ret;
    }

    // a method to get all employees
    function getAllEmployees() public view returns (Employee[] memory) {
        return employees;
    }

    // event emitted when a transfer is made
    event TransferMade(address _fromAddress, address _to, uint256 _value);

    // a function that makes the transaction to the Employee or Employer
    function payEmployeeOrEmployer(address payable to, uint256 amount)
        public
        payable
    {
        // get the employee to get paid
        Employee memory cur_emp = employeez[to];

        // check status
        if (cur_emp.contractStatus == ContractStatus.ACTIVATED) {
            // to.transfer(5 ether);
            to.transfer(amount);
            emit TransferMade(address(this), to, amount);
            cur_emp.contractStatus = ContractStatus.ENDED;
        }
    }

    // event emitted when ether received
    event Received(address add, uint256 amount, uint256 gas);

    // to receive ether into this smart contract
    receive() external payable {
        emit Received(msg.sender, msg.value, gasleft());
    }

    // event emitted when a escrow is made
    event EscrowMade(address _fromAddress, address _to, uint256 _value);

    // function that implements the escrow concept
    function escrow() external payable {
        // Just to show you how you can access the sent wei
        if (msg.value < 1000) {
            revert();
        }
        emit EscrowMade(msg.sender, address(this), msg.value);
    }
}
