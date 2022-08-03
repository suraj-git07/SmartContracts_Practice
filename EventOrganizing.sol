// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract EventContract {
    struct Event {
        address organizer;
        string name;
        uint256 date;
        uint256 price;
        uint256 ticketCount;
        uint256 ticketRemaing;
    }

    mapping(uint256 => Event) public events;
    mapping(address => mapping(uint256 => uint256)) public tickets;
    uint256 public eventId;

    function createEvent(
        string memory _name,
        uint256 _date,
        uint256 _price,
        uint256 _ticketCount
    ) external {
        require(_date > block.timestamp, "Event Date is gone");
        require(_ticketCount > 0, "You have no ticket");
        events[eventId] = Event(
            msg.sender,
            _name,
            _date,
            _price,
            _ticketCount,
            _ticketCount
        );
        eventId++;
    }

    function buyTicket(uint256 _eventId, uint256 _quantity) external payable {
        require(
            events[_eventId].date != 0 &&
                events[_eventId].date > block.timestamp,
            "event not exits or happend in past"
        );
        require(events[_eventId].ticketRemaing > 0, "HouseFull");

        Event storage _event = events[_eventId];

        require(
            (msg.value) == (_event.price * _quantity),
            "Ticket is expensive for you"
        );

        tickets[msg.sender][_eventId] += _quantity;
        _event.ticketRemaing -= _quantity;
    }

    function transferTicket(
        uint256 _eventId,
        uint256 _quantity,
        address _to
    ) external {
        require(
            events[_eventId].date != 0 &&
                events[_eventId].date > block.timestamp,
            "event not exits or happend in past"
        );
        require(
            tickets[msg.sender][_eventId] >= _quantity,
            "Not have enough Tickets"
        );
        tickets[msg.sender][_eventId] -= _quantity;
        tickets[_to][_eventId] += _quantity;
    }
}
