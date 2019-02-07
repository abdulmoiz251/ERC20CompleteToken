pragma solidity >=0.4.22 <0.6.0;

import "./SafeMath.sol";
import "./AMToken.sol";


contract CrowdSale {
    using SafeMath for uint;

    address public beneficiary;
    uint public fundingGoal;
    uint public price;
    uint public amountRaised;
    uint public deadline;
    bool public isGoalReached = false;
    bool public isCrowdSaleClosed = false;

    mapping(address => uint) public balanceOf;
    AMToken tokenAM = new AMToken();

    event GoalReached(address _recipent, uint _totalAmountRaised);
    event FundTransfered(address _recipent, uint _amountEther, bool _isPurchased);

    constructor (
        address _ifSuccessfulSendFundTo,
        uint _fundGoalInEther,
        uint _deadlineInMinutes,
        uint _costOfEachTokenInEther,
        address _addressOfToken
    )
        public
    {
        beneficiary = _ifSuccessfulSendFundTo;
        fundingGoal = _fundGoalInEther;
        deadline = now + _deadlineInMinutes;
        price = _costOfEachTokenInEther;
        beneficiary = _addressOfToken;
    }


    modifier afterDeadline() {
        require(now >= deadline);
        _;
    }


    function () payable external {
        require(!isCrowdSaleClosed);

        uint amount = msg.value;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        amountRaised = amountRaised.add(amount);
        tokenAM.transfer(msg.sender, amount/price);

        emit FundTransfered(msg.sender, amount, true);
    }


    function checkGoalReached () public afterDeadline {
        if(amountRaised >= fundingGoal) {
            isGoalReached = true;
        }
        isCrowdSaleClosed = true;
    }


    function withdraw() public afterDeadline {
        if(!isGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;

            if(amount > 0) {
                if(msg.sender.send(amount)) {
                    emit FundTransfered(msg.sender, amount, false);
                }
                else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }
        else if (isGoalReached && msg.sender == beneficiary) {
            if(msg.sender.send(amountRaised)) {
                emit FundTransfered(msg.sender, amountRaised, false);
            }
            else {
                isGoalReached = false;
            }
        }
    }
}
