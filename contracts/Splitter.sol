pragma solidity ^0.4.16;

// 3 people: Alice, Bob and Carol
// we can see the balance of the Splitter contract on the web page
// whenever Alice sends ether to the contract, half of it goes to Bob and the other half to Carol
// we can see the balances of Alice, Bob and Carol on the web page
// add a kill switch to the whole contract
// make the contract a utility
// cover potentially bad input data

contract Splitter {
    address public owner;

    mapping(address => uint256) public balances;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

	event Split(address indexed _from, address indexed _firstReceiver, address indexed _secondReceiver, uint256 _amount);
    event Killed(address indexed _owner);

    function Splitter(address firstReceiver, address secondReceiver) payable public {
        require(msg.value > 0);
        require(firstReceiver != address(0));
        require(secondReceiver != address(0));

        owner = msg.sender;
        balances[this] += msg.value;

        // No decimals
        // Problem if it is odd number
        uint256 remainder = msg.value % 2;
        if (remainder > 0) {
            balances[this] += remainder;
        }
             
        balances[firstReceiver] += msg.value/2;
        balances[secondReceiver] += msg.value/2;

        Split(msg.sender, firstReceiver, secondReceiver, msg.value);
    }

    function() payable public {
		revert();
	}

	function kill() public onlyOwner {
      	Killed(owner);
      	selfdestruct(owner);
    }
}