pragma solidity 0.4.15;

import "./Stoppable.sol";
import "./Hub.sol";

contract ResourceProposal is Stoppable {

	int chairmanFee;
	uint deadline;
	address chairman;
	int projectCost;
	bytes32 proposalText;
	bool isDependent;
	address depParent;
	int status;

	mapping(address => uint8) votes;
	//votes 0 is don't care, 1 yes, 2 no
	mapping(address => bytes32) opinions;
	address[] votesArray;
	
	modifier onlyIfMember() {
		//require(isMember(msg.sender));
		_;
	}

	event LogProposalCreated(address owner, address chairmanAddress, int fees, uint blocks, int cost, bytes32 text);
	event LogVoteCast(address member, uint8 vote);
	event LogProposalSentToHub(address owner, uint blockNumber);
	event LogOpinionAdded(address member, bytes32 opinion);

	function ResourceProposal(address chairmanAddress, int fees, uint blocks, int cost, bytes32 text) {
		chairman = chairmanAddress;
		chairmanFee = fees;
		deadline = block.number + blocks;
		projectCost = cost;
		proposalText = text;
		LogProposalCreated(owner, chairmanAddress, fees, blocks, cost, text);
	}

	function getChairman()
		public
		constant
		returns(address)
	{
		return chairman;
	}
	
	function getStatus()
		public
		constant
		returns(uint8)
	{
		return status;
	}


	function castVote(uint8 voteOfMember)
		public
		onlyIfMember
		onlyIfRunning
		returns(bool)
	{
		votes[msg.sender] = voteOfMember;
		votesArray.push()
		LogVoteCast(msg.sender, voteOfMember);
		return true;
	}

	function giveOpinion(bytes32 opinion)
		public
		onlyIfMember(msg.sender)
		returns(bool)
	{
		opinions[msg.sender] = opinion;

		LogOpinionAdded(msg.sender, opinion);
		return true;
	}


	function sendToHub()
		public
		returns(bool)
	{
		address[] memory addrForHub;
		uint8[] memory votesForHub;

		int count = votesArray.length;
		
		for(int i=0; i<count; i++)
		{
			uint8 val = votes[votesArray[i]];

			if(val==1 || val==2){
				addrForHub.push(votesArray[i]);
				votesForHub.push(val);
			}
		}

		return executeProposal(addrForHub,votesForHub);
	}
}