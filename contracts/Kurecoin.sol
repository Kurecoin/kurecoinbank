pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import './ERC223Interface.sol';
import './ERC223ReceivingContract.sol';
import './SafeMath.sol';
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";



/**
 * @title Reference implementation of the ERC223 standard token.
 */
contract Kurecoin is StandardToken, ERC223Interface, Ownable, Pausable, Destructible{
  using SafeMath for uint;

  string public name = "Kurecoin";      //  (token name)

  string public symbol = "KRC";           //  (token symbol)

  uint256 public decimals = 18;            //   (token digit)

  uint256 public totalSupply = 100000000 * (10**decimals);   // (total supply)

  mapping(address => uint) balances; // List of user balances.

  function Kurecoin (){

    balances[msg.sender] = totalSupply;

  }



  /**
   * @dev Transfer the specified amount of tokens to the specified address.
   *      Invokes the `tokenFallback` function if the recipient is a contract.
   *      The token transfer fails if the recipient is a contract
   *      but does not implement the `tokenFallback` function
   *      or the fallback function to receive funds.

   * @param _to    Receiver address.
   * @param _value Amount of tokens that will be transferred.
   * @param _data  Transaction metadata.
   */
  function transfer(address _to, uint _value, bytes _data) whenNotPaused {
    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    uint codeLength;

    assembly {
    // Retrieve the size of the code on target address, this needs assembly .
      codeLength := extcodesize(_to)
    }

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    if(codeLength>0) {
      ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
      receiver.tokenFallback(msg.sender, _value, _data);
    }
    emit Transfer(msg.sender, _to, _value, _data);
  }

  /**
   * @dev Transfer the specified amount of tokens to the specified address.
   *      This function works the same with the previous one
   *      but doesn't contain `_data` param.
   *      Added due to backwards compatibility reasons.
   *
   * @param _to    Receiver address.
   * @param _value Amount of tokens that will be transferred.
   */
  function transfer(address _to, uint _value) whenNotPaused {
    uint codeLength;
    bytes memory empty;

    assembly {
    // Retrieve the size of the code on target address, this needs assembly .
      codeLength := extcodesize(_to)
    }

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    if(codeLength>0) {
      ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
      receiver.tokenFallback(msg.sender, _value, empty);
    }
    emit Transfer(msg.sender, _to, _value, empty);
  }


  /**
   * @dev Returns balance of the `_owner`.
   *
   * @param _owner   The address whose balance will be returned.
   * @return balance Balance of the `_owner`.
   */
  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function setName(string _name) onlyOwner public {
    name = _name;
  }

  function setSymbol(string _symbol) onlyOwner public {
    symbol = _symbol;
  }

  function refundToken(address _from, address _to, uint amount) onlyOwner public returns (bool) {
    require(balances[_from] >= amount);
    balances[_from] = balances[_from].sub(amount);
    balances[_to] = balances[_to].add(amount);
    return true;
  }
}
