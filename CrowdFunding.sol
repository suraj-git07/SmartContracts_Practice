// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding{

    // contributor=>contribution
    mapping(address=>uint) public contributors; //default 0x00=>00

    address public manager;
    uint public minContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    //Request Structure
    struct Request{
        string description;
        address payable recipient;
        uint value;
        uint noOfVoters; // how many to contri votes
        mapping(address=>bool) voters;
        bool completed;

    }

    // multiple request can come
    mapping(uint=>Request) public request;
    uint public numRequest;

    constructor(uint _target,uint _deadline) {
        target = _target;
        
        // block.timestamp gives a global variable which is basically time in sec (from the unix start till block genration)
        deadline = block.timestamp + _deadline;
        minContribution = 100 wei;
        manager= msg.sender;
    }

    function sendEth() public payable{
        require(block.timestamp<deadline,"Deadline has passed"); // check whether the deadline passed or not
        require(msg.value>=minContribution,"Minimum Contribution is not meet");

        //check whether the contributor is first time contributor or not
        // The entire storage space is virtually initialized to 0 (there is no undefined). 
        // So you have to compare the value to the 0 value for your type
        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount+=msg.value;
    }

    // function getContribution(address _add) public view returns(uint){
    //     require(contributors[_add] != 0,"this address is not a contributor");
    //     return contributors[_add];
    // }

    // function getContractBalance() public view returns(uint){
    //     //  balance method on address give balance for that address 
    //     return address(this).balance;
    // }

    // REFUND CASE
    function refund() public {
        require(block.timestamp>deadline && target>raisedAmount,"You are not eligible to take refund ");
        require(contributors[msg.sender]>0,"You are not eligible to take refund ");

        // to transfer wei we have to use transfer func to that address , also that address has to be payable

        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0; 
    }

    // Manager's Functions


    // Function Modifiers are used to modify the behaviour of a function. 
    // For example to add a prerequisite to a function.

    // The function body is inserted where the special symbol "_;" appears in the definition of a modifier. 
    // So if condition of modifier is satisfied while calling this function, 
    // the function is executed and otherwise, an exception is thrown.
    
    modifier onlyManager(){
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    function createRequest(string memory _description,address payable _recipient,uint _value) public onlyManager{
        
        // to use mapping in a struct and then that struct in function we have to initilize that struct as storage in func
        Request storage newRequest = request[numRequest];
        numRequest++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"You must be a contributor");
        Request storage thisRequest = request[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint _requestNo) public onlyManager{
        Request storage thisRequest = request[_requestNo];
        require(raisedAmount>=target && raisedAmount>=thisRequest.value );
        require(thisRequest.completed==false,"The Request has been completed");
        require(thisRequest.noOfVoters>noOfContributors/2,"Majority does not voted or support this request");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
    }
}
