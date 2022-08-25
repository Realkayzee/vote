// SPDX-License-Identifier: GPL-3.0


pragma solidity 0.8.9;


/// @title Voting Contract
/// @author Kayzee
// Officials state the maximum number of people to be voted for
// Once the maximum number is attained officials won't accept aspirants
// Each contestant have their voting number as given by the officials
// voters can vote for any aspirant base on the aspirants voting number
// voters must register before voting
// result is being cumulated after a particular time of the start of election


contract Voting{
    address official;
    address[] registeredVoters;
    bool electionStarted;
    uint256 maxNumberVoters;
    uint256 contestantNumber;
    uint128 id;


    struct Voters{
        bool registered;
        bool voted;
    }

    Voters[] RegisteredVoters;


    struct ContestantDetails {
        address contestant;
        string contestantName;
        uint128 contestantId;
        bool contested;
    }

    ContestantDetails[] registeredContestant;

    mapping(address => Voters) voter;
    mapping(address => ContestantDetails) contestant;


    constructor (address _officialAddr, uint256 _maxNumber, uint256 _contestantNumber) {
        official = _officialAddr;
        maxNumber = _maxNumber;
        contestantNumber = _contestantNumber;
    }

    modifier onlyOfficial{
        require(msg.sender == official, "You are not an official");

        _;
    }

// Function that enable voters to register

    function RegVoter() external {
        require(!electionStarted, "You can't vote, election started already");
        require(RegisteredVoters.length < maxNumberVoters, "Maximum number of voters already attained");
        Voters storage v = voter[msg.sender];
        v.registered = true;
        
    }
// Function that enable contestant to register
    function RegContestant(string memory _contestantName) public {
        require(!contested, "You can not register as a contestant again");
        require(registeredContestant.length < contestantNumber, "Contestant number already attained");
        registeredContestant.push(
            ContestantDetails({
                contestant: msg.sender,
                contestantName: _contestantName,
                contestantId: id
            })
        );
        id++;
    }

    function startElection() public onlyOfficial {
        require(!electionStarted, "Election Already started");
        require(registeredContestant.length == contestantNumber, "All contestant have not regiatered");
        require()
    }
        
    }
}