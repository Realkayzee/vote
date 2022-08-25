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
    //****State Variable */
    address official;
    bool started;
    bool electionStarted;
    uint256 maxNumberVoters;
    uint256 contestantNumber;
    ContestantDetails winner;
    uint256 electionPeriod;


    struct Voters{
        bool registered;
        bool voted;
    }

    Voters[] RegisteredVoters;


    struct ContestantDetails {
        string contestantName;
        uint128 contestantId;
        bool contested;
        uint128 numberOfVote;
    }

    ContestantDetails[] registeredContestant;

    mapping(address => Voters) voter;
    mapping(address => ContestantDetails) contestant;

/// @notice _electionPeriod is in hours, users specify the period they want the election to last in hours
    constructor (address _officialAddr) {
        official = _officialAddr;

    }

    modifier onlyOfficial{
        require(msg.sender == official, "You are not an official");

        _;
    }
    modifier electionNotStarted{
        require(!electionStarted, "You can't vote, election started already");

        _;
    }

    function start(uint256 _maxNumber, uint256 _contestantNumber, uint256 _electionPeriod) external onlyOfficial electionNotStarted {
        require(!started, "The election process have started");
        maxNumberVoters = _maxNumber;
        contestantNumber = _contestantNumber;
        electionPeriod = _electionPeriod * (1 hours);

        started = true;
    }

// Function that enable voters to register

    function RegVoter() external electionNotStarted {
        require(started, "Election Process have not started");
        Voters storage v = voter[msg.sender];
        require(!v.registered, "You are have registered");
        require(RegisteredVoters.length < maxNumberVoters, "Maximum number of voters already attained");
        v.registered = true;

        RegisteredVoters.push(v);

    }
// Function that enable contestant to register
    function RegContestant(string memory _contestantName) public electionNotStarted {
        require(started, "Election Process have not started");
        ContestantDetails storage c = contestant[msg.sender];
        require(!c.contested, "You can not register as a contestant again");
        require(registeredContestant.length < contestantNumber, "Contestant number already attained");
        c.contestantName = _contestantName;
        c.contested = true;
        c.contestantId = uint128(registeredContestant.length);
        registeredContestant.push(c);
    }

    function startElection() public onlyOfficial electionNotStarted {
        require(started, "Election Process have not started");
        require(registeredContestant.length == contestantNumber, "All contestant have not regiatered");
        
        electionStarted = true;
    }
    
    function vote(uint256 _contestantId) external {
        Voters storage v = voter[msg.sender];
        require(electionStarted, "Election have not started");
        require(v.registered, "You are not a registered voter");
        require(!v.voted, "You can not vote twice");
        registeredContestant[_contestantId].numberOfVote += 1;

        v.voted = true;
    }

    function electionCollation() public onlyOfficial {
        ContestantDetails memory con;
        require(block.timestamp > electionPeriod, "Election is still going on");
        electionStarted = true;

        // We check the modal for the number of vote
        uint128 winnerCounter;
        for(uint256 i = 0; i < registeredContestant.length; i++){
            if(winnerCounter < registeredContestant[i].numberOfVote){
                winnerCounter = registeredContestant[i].numberOfVote;
                con = registeredContestant[i];
            }
        }
        winner = con;
        // reset the all state variable back to normal
        electionStarted = false;
        started = false;
        maxNumberVoters = 0;
        contestantNumber = 0;
        electionPeriod = 0;
    }

    function checkWinner() external view returns(ContestantDetails memory){
        return winner;
    }

    function checkContestant() external view returns(ContestantDetails[] memory){
        return registeredContestant;
    }

    function checkVoters() external view returns(Voters[] memory){
        return RegisteredVoters;
    }

    function checkIfRegistered() external view returns(bool){
        return voter[msg.sender].registered;
    }
    function checkIfVoted() external view returns(bool){
        return voter[msg.sender].voted;
    }
}