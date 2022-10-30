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
        address employeeAddress;
        uint256 contractDuration;
        uint256 contractStartDate;
        string employeeRole;
        ContractStatus contractStatus;
        uint256 balanceInWei;
        int256 locLat;
        uint256 latOffset;
        int256 locLon;
        uint256 lonOffset;
        uint256 acceptedRange;
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
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

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

    constructor() {
        // set the contract's owner (employer)
        employer = Employer("f0xtr0t", msg.sender, "Forward Operations Base");

        numberOfEmployeesCount = 0;
        numberOfTrackedLocations = 0;
        compDetailUpdateStatus = "";
    }

    // A method to create employees
    function createEmployee(
        string memory name,
        address employeeAddress,
        uint256 contractDuration,
        string memory employeeRole,
        int256 latitude,
        uint256 latitudeOffset,
        int256 longitude,
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

    // A method to track employee location
    function trackLocation(
        int256 latitude,
        uint256 latitudeOffset,
        int256 longitude,
        uint256 longOffset
    ) public payable {
        // the location track date
        uint256 locationUpdatedAt = block.timestamp;

        // the employee name
        string memory employeeName = employeez[msg.sender].name;

        locations.push(
            Locations(
                employeeName,
                msg.sender,
                latitude,
                latitudeOffset,
                longitude,
                longOffset,
                locationUpdatedAt
            )
        );

        numberOfTrackedLocations++;
        emit LocationTracked(employeeName, msg.sender, locationUpdatedAt);
    }

    // A method to get balance in wei
    function getBalance(address balanceAddress) public view returns (uint256) {
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

    // A method to get the distance between two points
    function getDistance(
        int256 lat,
        int256 lng,
        int256 lat1,
        int256 lng1
    ) private pure returns (int256) {
        int256 dist = sqrt(((lat - lat1)**2) + ((lng - lng1)**2));
        return dist;
    }

    // A method to check employee distance range
    function checkEmployeeRange(
        address add,
        uint256 lat,
        uint256 lon
    ) private {
        // get the agreed range
        uint256 agreedRange = employeez[add].acceptedRange;

        // get the employee assigned location
        int256 lat1 =  employeez[add].latitude;
        int256 lon1 =  employeez[add].longitude;

        // get the distance between the current location and the agreed location
        int256 currentRange = getDistance(lat, lon, lat1, lon1);

        if (currentRange > agreedRange) {
            // fail the contracts state
        }
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
