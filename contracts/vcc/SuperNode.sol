pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";

contract SuperNode is Ownable {
    using SafeMath for uint256;

    struct Node {
        address payable addr;
        uint256 activeBlockNum;
        uint256 activeAmount;
        uint256 nodeArrayIndex;
    }


    mapping (address=>uint256) public superNodeFlag;
    mapping (address=>Node) public superNodeInfo;


    address[] public superNodeArray;
    uint256 public superNodeNeedLockAmount;
    uint256 public superNodeCount;
    uint256 public superNodeLockAmount;

    constructor() public payable{
        superNodeCount = 0;
        superNodeNeedLockAmount = 126000000000000000000000;
    }

    function() external payable {
        require(!Address.isContract(msg.sender), "not a human!");
        require(msg.value == superNodeNeedLockAmount, "amount do not match to what the contract need!");
        require(superNodeFlag[msg.sender]!=1,"this address is a super node already!");

        superNodeArray.push(msg.sender);
        superNodeCount = superNodeCount.add(1);
        superNodeLockAmount = superNodeLockAmount.add(msg.value);
        superNodeFlag[msg.sender] = 1;
        Node memory node = Node(msg.sender,block.number,superNodeNeedLockAmount,superNodeArray.length-1);
        superNodeInfo[msg.sender] = node;
    }

    function withdraw() external{
        require(!Address.isContract(msg.sender), "not a human!");
        require(superNodeFlag[msg.sender]==1,"this address is not a super node!");

        Node memory node = superNodeInfo[msg.sender];
        superNodeCount = superNodeCount.sub(1);
        superNodeLockAmount = superNodeLockAmount.sub(node.activeAmount);
        superNodeFlag[msg.sender] = 0;

        superNodeArray[node.nodeArrayIndex] = address(0x0);
        msg.sender.transfer(node.activeAmount);
    }


    function queryAllSuperNodeAddreses() public view returns(address[] memory){
        address[] memory returnArray = new address[](superNodeCount);
        uint256 nodeIndex = 0;
        for(uint256 i = 0;i < superNodeArray.length;i++){
            address nodeAddr = superNodeArray[i];
            if(superNodeFlag[nodeAddr] == 1 && nodeAddr != address(0x0)){
                returnArray[nodeIndex] = nodeAddr;
                nodeIndex = nodeIndex.add(1);
            }
        }
        return returnArray;
    }


    function queryNeedCountSuperNodeAddreses(uint256 _needCount) public view returns(address[] memory){
        uint256 realCount = _needCount;

        if(_needCount>superNodeCount){
            realCount = superNodeCount;
        }

        address[] memory returnArray = new address[](realCount);
        uint256 nodeIndex = 0;
        for(uint256 i = 0;i < superNodeArray.length;i++){
            address nodeAddr = superNodeArray[i];
            if(superNodeFlag[nodeAddr] == 1 && nodeAddr != address(0x0)){
                returnArray[nodeIndex] = nodeAddr;
                nodeIndex = nodeIndex.add(1);
                if(nodeIndex>=realCount){
                    break;
                }
            }
        }
        return returnArray;
    }

    function queryNodeInfo(address _nodeAddress) public view returns (address addr,uint256 activeBlockNum,uint256 activeAmount){
        Node memory node = superNodeInfo[_nodeAddress];
        if(superNodeFlag[_nodeAddress]==1){
            addr = node.addr;
            activeBlockNum = node.activeBlockNum;
            activeAmount = node.activeAmount;
        }else{
            addr = address(0x0);
            activeBlockNum = 0;
            activeAmount = 0;
        }
    }


    function judgeSuperNode(address _nodeAddress) public view returns (bool) {
        uint256 flag = superNodeFlag[_nodeAddress];
        if(flag==1){
            return true;
        }else{
            return false;
        }
    }

    function refreshSuperNodeNeedLockAmount(uint _superNodeNeedLockAmount) external onlyOwner{
        superNodeNeedLockAmount = _superNodeNeedLockAmount;
    }

    function refreshSuperNodeActiveBlock(address _superNodeAddr) external onlyOwner{
        require(superNodeFlag[_superNodeAddr]==1,"this address is not a super node!");
        //remove the old one
        Node memory oldNode = superNodeInfo[_superNodeAddr];
        superNodeArray[oldNode.nodeArrayIndex] = address(0x0);

        //add new one
        superNodeArray.push(_superNodeAddr);
        oldNode.activeBlockNum = block.number;
        oldNode.nodeArrayIndex = superNodeArray.length-1;
        superNodeInfo[_superNodeAddr] = oldNode;
    }
}