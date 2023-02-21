// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/**
 * Money Transfer Smart Contract
 * This contracts allows a grantor to transfer money with time maturity to one or more beneficiaries
 */
contract MonetaryTransfer {

    struct Beneficiary {
        uint256 amount;
        uint256 maturity;
        bool paid;
    }

    mapping(address => Beneficiary) public beneficiaries;
    address public grantor;

    constructor() {
        grantor = msg.sender;
    }

    function addBeneficiary(address beneficiary, uint256 timeToMaturity) external payable {
        require(msg.sender == grantor, "Only the grantor can set up the beneficiary");
        require(beneficiaries[msg.sender].amount == 0, "The beneficiary already exists");
        beneficiaries[beneficiary] = Beneficiary(msg.value, block.timestamp + timeToMaturity, false);
    }

    uint256 public maturity;

    function withdraw() external {
        Beneficiary storage beneficiary = beneficiaries[msg.sender];
        require(beneficiary.maturity <= block.timestamp, "The maturity time has not yet expired");
        require(beneficiary.amount > 0, "Only the beneficiary can withdrawn the funds");
        require(beneficiary.paid == false, "The funds have been already withdrawn");
        beneficiary.paid = true;
        payable(msg.sender).transfer(beneficiary.amount);
    }
}
