// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract ERC20 {
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 private _totalSupply;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    event Transfer(address indexed Owner, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);

    constructor() {
        name = "Kiyoko";
        symbol = "KY";
        decimals = 18;
        _totalSupply = 1000000000*10**18;

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view returns (uint256 tokens){
        return _totalSupply;
    }
    function balanceOf(address _address) public view returns (uint256 tokens){
        return balances[_address];
    }
    function transfer(address _to, uint256 _tokens)  public returns (bool success){
        require(_tokens <= balances[msg.sender], "You have insufficient balance"); 
        balances[msg.sender] = balances[msg.sender] - _tokens;
        balances[_to] = balances[_to] = _tokens;
        emit Transfer(msg.sender, _to, _tokens);
        return true;
    } 
    function approve(address _spender, uint256 _tokens) public returns (bool success){
        allowed[msg.sender][_spender] = _tokens;
        emit Approval(msg.sender, _spender, _tokens);
        return true;
    }
    function transferFrom(address _owner, address _to, uint256 _tokens) public returns (bool success){
        require(_tokens <= balances[_owner], "Owner does not have sufficient tokens");
        require(_tokens <= allowed[_owner][msg.sender], "Limit Exceeded");
        balances[_owner] = balances[_owner] - _tokens; 
        balances[_to] = balances[_to] + _tokens;      
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender] - _tokens;
        emit Transfer( _owner, _to, _tokens);
        return true;
    }
    function allowance(address _owner, address _spender) public view returns (uint256 remainingTokens){

        return allowed[_owner][_spender];
    }

}
