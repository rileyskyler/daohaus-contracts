pragma solidity ^0.4.15;

import "./Stoppable.sol";
import "./ResourceProposal.sol";

contract Hub is Stoppable {

  mapping (address => uint) amountsPledgedMapping;
  address[] members;
  uint public totalCurrentBalance;
  uint public totalAllTimeBalance;
  uint public totalBalance;
  address[] public proposals;
  mapping(address => bool) proposalExists;

  event LogMemberRegistered(address member, uint ethPledge, uint currentBalance, uint allTimeBalance);
  modifier onlyIfProposal(address proposal) {
    if (proposalExists[proposal] != true) {
        revert();
    }
    _;
  }

  event LogNewProposal(address chairmanAddress, int fees, uint blocks, int cost, bytes32 text);
  event LogMemberRegistered(address member, uint ethPledge, uint totalContractBalance);

  function Hub() {}

  function register()
    public
    payable
    sufficientFunds()
  {
    /* update hub contract balance */
    totalCurrentBalance += msg.value;
    totalAllTimeBalance += msg.value;

    /* update amountsPledged mapping */
    amountsPledgedMapping[msg.sender] += msg.value;

    /* update members array */
    members.push(msg.sender);

    LogMemberRegistered(
      msg.sender,
      msg.value,
      totalCurrentBalance,
      totalAllTimeBalance
    );
  }

  function getMembersCount()
    constant
    public
    returns (uint count)
  {
    return members.length;
  }

  function getVotingRightRatio(address member)
    constant
    public
    returns (uint ratio)
  {
    return amountsPledgedMapping[member] / totalAllTimeBalance;
  }

  /*function propose(uint ethAmount, string proposalMessage) {
    address proposer = msg.sender;
  }*/

  modifier sufficientFunds() {
    require(msg.value > 0);
    _;
  }

   function getProposalCount()
        public
        constant
        returns(uint proposalCount)
    {
        return proposals.length;
    }
    
    function createResourceProposal(
      address chairmanAddress, 
      int fees, 
      uint blocks, 
      int cost, 
      bytes32 text
    )
        public
        returns(address campaignContract)
    {
      ResourceProposal trustedProposal = new ResourceProposal(
        chairmanAddress,
        fees,
        blocks,
        cost,
        text
      );
      proposals.push(trustedProposal);
      proposalExists[trustedProposal] = true;
      LogNewProposal(chairmanAddress, fees, blocks, cost, text);
      return trustedProposal;
    }
    
    // Pass-through Admin Controls
    function stopProposal(address proposal) 
        onlyOwner
        onlyIfProposal(proposal)
        returns(bool success)
    {
        ResourceProposal trustedProposal = ResourceProposal(proposal);
        return(trustedProposal.runSwitch(false));
    }

}
