pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract PoolSplitter is Ownable{
    using SafeMath for uint256;

    event PaymentReceived(address from, uint256 amount);

    address[] private _payees;

    mapping (address=>uint256) private _payeesMap;
    mapping(address => uint256) private _shares;

    mapping(address => uint256) private _amounts;

    mapping(address => uint256) private _withdraws;

    uint256 public totalShared = 0;

    /**
     * @dev Constructor
     */
    constructor () public payable {
    }

    /**
     * @dev payable fallback
     */
    function () external payable {

        if(totalShared != 0){
            for(uint256 i = 0;i < _payees.length;i++){
                uint256 payeeShares = _shares[_payees[i]];
                if(payeeShares>0){
                    uint256 payment = msg.value.mul(_shares[_payees[i]]).div(totalShared);
                    _amounts[_payees[i]] = _amounts[_payees[i]].add(payment);
                }
            }
        }

        emit PaymentReceived(msg.sender, msg.value);
    }


    function etherProceeds() external onlyOwner
	{
        for(uint256 i = 0;i < _payees.length;i++){
            _amounts[_payees[i]] = 0;
        }
        // if(!) revert("ethProceeds error");
        msg.sender.transfer(address(this).balance);
    }


    function withdrawByOwner(address payable account) external onlyOwner{
        require(_amounts[account]>0, "not enought amount!");
        uint256 withdrawAmount = _amounts[account];
        _amounts[account] = 0;
        _withdraws[account] = _withdraws[account].add(withdrawAmount);
        account.transfer(withdrawAmount);

    }

    function withdraw() external
    {
        require(_amounts[msg.sender]>0, "not enought amount!");
        uint256 withdrawAmount = _amounts[msg.sender];
        _amounts[msg.sender] = 0;
        _withdraws[msg.sender] = _withdraws[msg.sender].add(withdrawAmount);
        msg.sender.transfer(withdrawAmount);
    }

    function payees(uint256 _index) public view returns (address) {
        return _payees[_index];
    }

    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    function amounts(address account) public view returns (uint256) {
        return _amounts[account];
    }

    function withdraws(address account) public view returns (uint256) {
        return _withdraws[account];
    }
    function payeesMap(address account) public view returns (uint256) {
        return _payeesMap[account];
    }

    function refreshPayeesShares(address[] calldata account_, uint256[] calldata shares_) external onlyOwner {
        require(account_.length>0, "account array empty");
        require(account_.length==shares_.length,"account length not equal to shares_ length");

        for(uint256 i = 0;i < _payees.length;i++){
            _shares[_payees[i]] = 0;
        }
        totalShared = 0;

        for(uint256 i = 0;i < account_.length;i++){
            _shares[account_[i]] = shares_[i];
            if(_payeesMap[account_[i]]!=1){
                _payees.push(account_[i]);
                _payeesMap[account_[i]] = 1;
            }
            totalShared = totalShared.add(shares_[i]);
        }
    }
}