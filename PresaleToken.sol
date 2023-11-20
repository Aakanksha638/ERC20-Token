// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


pragma solidity 0.8.21;

interface ITokenSale {  
        function getname() external view returns (string memory);

        function getsymbol() external view returns (string memory);

        function decimals() external view returns (uint8);

        function TotalSupply() external view returns (uint256);

        function balanceof(address owner) external view returns (uint256);

        function allowance(address owner, address spender)
        external
        view 
        returns (uint256);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract TokenSale is ITokenSale {
    using SafeMath for uint256;

    ITokenSale public INV = ITokenSale(); //Contract Address
    AggregatorV3Interface public priceFeedEth;

    address payable public owner;

    uint256 public tokenPerUSDT = 10000000000000000000; //10 Tokens for $1
   
    uint256 public PresaleStartTime;
    uint256 public soldToken;
    uint256 public totalSupply = 1000000000; //Presales Token
    uint256 public amountRaisedUSDT;
    uint256 public minimumDollar = 100; //min buy in USDT
    //uint256 public minimumETH = 0.049 ether; // min Eth
    string public symbol;
    string public name;
    uint8 public decimalNumber;
    uint256 public constant divider = 100;

    bool public presaleStatus;

    struct user {
      uint256 Eth_balance;
      uint256 INV_balance; 

      uint256 usdt_balance;
      uint256 token_balance;

      uint256 USDT_balance;
    }

    mapping(address => mapping(address => uint256)) public allowed;
    mapping(address => user) public users; 
    mapping(address => uint256) public balances;


    modifier onlyOwner() {
      require(msg.sender == owner, "Presale: Not an Owner");
      _;
    }

    event BuyToken(address indexed _user, uint256 indexed _amount);

    constructor() {
      owner = payable();
      priceFeedEth = AggregatorV3Interface(
          0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46
      ); // Aggregrator address
      PresaleStartTime = block.timestamp;
      presaleStatus = true;
      //symbol = "INV";
      //name = "INVTRON DAO";
      //decimalNumber = 18;
    }
    receive() external payable {
        
    }  

    function TotalSupply() external override view returns (uint256) {
    return totalSupply;
}

function balanceof(address account) external override view returns (uint256) {
    return balances[account];
}

function allowance(address account, address spender) external override view returns (uint256) {
    return allowed[account][spender];
}

function approve(address spender, uint256 value) external override returns (bool) {
    allowed[msg.sender][spender] = value;
    emit approval(msg.sender, spender, value);
    return true;
}

function decimals() external override view returns (uint8) {
    return decimalNumber;
}

function getname() external override view returns (string memory) {
    return name;
}

function getsymbol() external view returns (string memory) {
    return symbol;
}

function transfer(address to, uint256 value) external override returns(bool success) {
    require(balances[msg.sender] >= value);
    balances[msg.sender] -= value;
    balances[to] += value;
    emit Transfer(msg.sender, to, value);
    return true;
}

function transferFrom(address from, address to, uint256 value) external override returns (bool) {
    require(value <= balances[from]);
    require(value <= allowed[from][msg.sender]);
    
    balances[from] -= value;
    balances[to] += value;
    allowed[from][msg.sender] -= value;
    
    emit Transfer(from, to, value);
    return true;
}

    // to get real time price of Eth
function getLatestPriceEth() public view returns (uint256) {
    (, int256 price, , ,) = priceFeedEth.latestRoundData();
    return uint256(price);
}

/* Example function to convert ETH to tokens
    function EthToToken(uint256 ethAmount) internal view returns (uint256) {
    // Assuming 1 ETH = 203.987 tokens, multiply by 1000 for precision
    uint256 tokensPerEth = 203987; // 203.987 * 1000
    return ethAmount * tokensPerEth / 1000;
}
*/

    function USDTToToken(uint256 USDTAmount) internal pure returns (uint256) {
        // For simplicity, let's assume 1 USDT = 10 tokens
        uint256 tokenPerUsdt = 10000000000000000000;
        return USDTAmount * tokenPerUsdt;
    }



    // to buy token during preSale time with USDT => for web3 use

    function buyTokenUSDT(uint256 _USDTAmount) public payable {
      require(presaleStatus == true, "Presale : Presale is finished");
      require(msg.value >= minimumDollar, "Minimum Amount is $100");
      require(soldToken <= totalSupply, "All Sold");

       // Convert USDT to tokens
    uint256 numberOfTokens = USDTToToken(_USDTAmount);

    // Ensure that the contract has enough tokens to sell
    require(numberOfTokens <= totalSupply.sub(soldToken), "Not enough tokens left");


      //require(INV.transfer(msg.sender, numberOfTokens), "Token transfer failed");
      
  
      /* 
      numberOfTokens = USDTToToken(msg.value);
      INV.transfer(msg.sender, numberOfTokens);
*/


      soldToken = soldToken + (numberOfTokens);
      amountRaisedUSDT = amountRaisedUSDT + (msg.value);
      users[msg.sender].USDT_balance = 
      users[msg.sender].USDT_balance + (_USDTAmount);

      users[msg.sender].token_balance = 
      users[msg.sender].token_balance + (numberOfTokens);
    }
}
