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

	event SplitterCreated(address indexed _from, address indexed _to, uint256 _amount, uint256 _deadline);
    event SendToContract(address indexed _sender, address indexed _contract, uint256 amount);
    event Split(address indexed _sender, address indexed _receiver, uint256 _amount);
    event Killed(address indexed _owner);

    function Splitter() public {
        owner = msg.sender;
    }

    function sendToContract() payable public returns (bool) {
        require(msg.value > 0);
        balances[this] += msg.value;

        SendToContract(msg.sender, this, msg.value);
        return true;
    }

    function split(address[] receivers) payable public returns (bool) {
        require(msg.value > 0);

        uint256 receiversCount = receivers.length;

        // No decimals
        // Problem if it is odd number
        uint256 remainder = msg.value % receivers.length;
        if (remainder > 0) {
            balances[msg.sender] += remainder;
        }

        for (var index = 0; index < receiversCount; index++) {
            address receiverAddress = receivers[index];
            require(receiverAddress != address(0));
             
            balances[receiverAddress] += msg.value/receiversCount;
            Split(msg.sender, receiverAddress, msg.value);
        }
        
        return true;
    }

    function() payable public {
		revert();
	}

	function kill() public {
        require(msg.sender == owner);
      	Killed(owner);
      	selfdestruct(owner);
    }
}