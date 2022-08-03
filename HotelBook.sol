// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// name to literal

contract HotelRoom {
    address payable owner;
    enum Statuses {
        Vacant,
        Occupied
    }

    Statuses public currentStatus;

    event Occupy(address _occupant, uint256 _value);

    constructor() {
        owner = payable(msg.sender);
        currentStatus = Statuses.Vacant;
    }

    // InSolidity, there are three ways in which one can send ether.
    //   transfer(), send() and call().

    // transfer -> the receiving smart contract should have a fallback function defined or else the transfer call will throw an error.
    //             There is a gas limit of 2300 gas, which is enough to complete the transfer operation.
    //             It is hardcoded to prevent reentrancy attacks.

    // send -> It works in a similar way as to transfer call and has a gas limit of 2300 gas as well.
    //         It returns the status as a boolean.

    // call ->It is the recommended way of sending ETH to a smart contract.
    //        The empty argument triggers the fallback function of the receiving address.
    //        (bool sent,memory data) = _to.call{value: msg.value}("");
    //        using call, one can also trigger other functions defined in the contract and send a fixed amount of gas to execute the function.
    //        The transaction status is sent as a boolean and the return value is sent in the data variable.

    modifier onlyVacant() {
        require(currentStatus == Statuses.Vacant, "Occupied");
        _;
    }
    modifier costs(uint256 _amount) {
        require(msg.value >= _amount, "Not enough amount send");
        _;
    }

    function book() public payable onlyVacant costs(2 ether) {
        // owner.transfer(msg.value);
        (bool sent, bytes memory data) = owner.call{value: msg.value}("");
        require(sent);

        currentStatus = Statuses.Occupied;

        emit Occupy(msg.sender, msg.value);
    }
}
