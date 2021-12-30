pragma solidity 0.6.0;
pragma experimental ABIEncoderV2;

contract Wallet {
  address[] public approvers;
  uint quorum;
  struct Transfer{
      uint id;
      uint amount;
      address payable to;
      uint approvals;
      bool sent;
  }

  Transfer[] public transfers; 
  mapping(address => mapping(uint => bool)) public approvals;

  constructor(address[] memory _approvers, uint _quorum) public {
    approvers = _approvers;
    quorum = _quorum;
  }

  function getValueOfQuorum() external view returns(uint){
    return quorum;
  }

  function getApprovers() external view returns(address [] memory) {
      return approvers;
  }

  function getTransfers() external view returns(Transfer [] memory) {
      return transfers;
  }

  function createTransfers(uint amount, address payable to) external onlyApprovers(){
      transfers.push(Transfer(
          transfers.length,
          amount,
          to,
          0,
          false
      ));
  } 

  function approveTransfer(uint id) external onlyApprovers() {
      require(transfers[id].sent == false, 'TRANSFER HAS ALREADY BEEN MADE');
      require(approvals[msg.sender][id] == false, 'CANNOT PERORM APPROVAL TWICE');

      approvals[msg.sender][id] = true;
      transfers[id].approvals++;

      if(transfers[id].approvals >= quorum){
        transfers[id].sent = true;
        address payable to = transfers[id].to;
        uint amount = transfers[id].amount;
        to.transfer(amount);
      }
  }
      receive() external payable {}

      modifier onlyApprovers(){
        bool allowed = false;
        for(uint i = 0; i < approvers.length; i++ ){
            if(approvers[i] == msg.sender){
              allowed = true;
            }
        }
        require(allowed == true, 'ONLY APPROVER ALLOWED');

        _;
      }
}