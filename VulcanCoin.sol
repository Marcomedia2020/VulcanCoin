pragma solidity ^0.5.17;

// ----------------------------------------------------------------------------
// Vulcan Labs Inc. / SPDX-License-Identifier: GPL-3.0
//
//__/\\\________/\\\___/\\\________/\\\___/\\\_____________________/\\\\\\\\\______/\\\\\\\\\______/\\\\\_____/\\\______________/\\\__________________/\\\\\\\\\______/\\\\\\\\\\\\\________/\\\\\\\\\\\___        
// _\/\\\_______\/\\\__\/\\\_______\/\\\__\/\\\__________________/\\\////////_____/\\\\\\\\\\\\\___\/\\\\\\___\/\\\_____________\/\\\________________/\\\\\\\\\\\\\___\/\\\/////////\\\____/\\\/////////\\\_       
//  _\//\\\______/\\\___\/\\\_______\/\\\__\/\\\________________/\\\/_____________/\\\/////////\\\__\/\\\/\\\__\/\\\_____________\/\\\_______________/\\\/////////\\\__\/\\\_______\/\\\___\//\\\______\///__      
//   __\//\\\____/\\\____\/\\\_______\/\\\__\/\\\_______________/\\\______________\/\\\_______\/\\\__\/\\\//\\\_\/\\\_____________\/\\\______________\/\\\_______\/\\\__\/\\\\\\\\\\\\\\_____\////\\\_________     
//    ___\//\\\__/\\\_____\/\\\_______\/\\\__\/\\\______________\/\\\______________\/\\\\\\\\\\\\\\\__\/\\\\//\\\\/\\\_____________\/\\\______________\/\\\\\\\\\\\\\\\__\/\\\/////////\\\_______\////\\\______    
//     ____\//\\\/\\\______\/\\\_______\/\\\__\/\\\______________\//\\\_____________\/\\\/////////\\\__\/\\\_\//\\\/\\\_____________\/\\\______________\/\\\/////////\\\__\/\\\_______\/\\\__________\////\\\___   
//      _____\//\\\\\_______\//\\\______/\\\___\/\\\_______________\///\\\___________\/\\\_______\/\\\__\/\\\__\//\\\\\\_____________\/\\\______________\/\\\_______\/\\\__\/\\\_______\/\\\___/\\\______\//\\\__  
//       ______\//\\\_________\///\\\\\\\\\/____\/\\\\\\\\\\\\\\\_____\////\\\\\\\\\__\/\\\_______\/\\\__\/\\\___\//\\\\\_____________\/\\\\\\\\\\\\\\\__\/\\\_______\/\\\__\/\\\\\\\\\\\\\/___\///\\\\\\\\\\\/___ 
//        _______\///____________\/////////______\///////////////_________\/////////___\///________\///___\///_____\/////______________\///////////////___\///________\///___\/////////////_______\///////////_____
//
// VulcanCoin - People's crypto - Hold long and Prosper! 
//
// VulcanCoin is a decentralized cryptocurrency that belongs to the people who hold it. 
// Vulcan is an automatic burning cryptocurrency with zero user fee contract.
// Vulcan was designed to be a simple and efficient highly deflationary asset, with a limited supply that will only decrease in time. 
// The deflationary nature of Vulcan is implemented by a function that burns 0.1% of the value of every  single transaction from a locked account (burn account) containing 30% of the total supply (6.300.000 coins). 
// The burn account is locked and the coins it contains cannot be transferred to a different address other than the burn TO address.
// Once the burnable supply of 6.3M Vulcan is finished, the total supply of Vulcan will be stable at 14.700.000 coins. 
// New Vulcan coins cannot be minted. 
// Like Bitcoin, Vulcan has a limited maximum supply of only 21 million coins (21,000,000). 
// Unlike Bitcoin, the 21M coins are pre-mined and will decrease in number in time due to transaction burning.
// The pre-mined nature of VulcanCoin makes it a Clean Energy asset, in contrast to the cryptocurrencies that demand constant mining.
//
// Hold long and prosper!
//
// Contract Main Parameters
//
// Contract address: 0x1983Da4B6F993E40B65E8549a322097e064fA1d4
// Bscscan page: https://bscscan.com/token/0x1983da4b6f993e40b65e8549a322097e064fa1d4
//
//
// Symbol           : VULCAN
// Name             : VulcanCoin
// Total supply(TS) : 21000000 (Twenty one million, initialy as scarce as Bitcoin. More scarce than BTC over time, due to the burning functionality)
// Decimals         : 18
// Coded at         : https://remix.ethereum.org/
// Deployed to      : 0x7285f1E4Cf01B72848720e8c66cb20FA025BABDC (Burn supply account, where 30% of TS will be kept for burning)
// Deployed at      : Binance Smart Chain (Bsc)
// BscTestnet vers. : 10 versions
// Burning specs    : 0.1% of all transactions are automatically burnt from the burn account to a null account.
// Trading Fees     : 0 (zero) by contract
// Burned from      : Burn supply, calculated (but not discounted from) buyer/seller transaction
// Liquidity        : Provided by liquidity fund, not from buyer/seller
//
//
//
// Initial Tokenomics:
// Burn supply (Locked) <= 30% of Total Supply (cannot increase, only decrease via burning)
// Developers Fund <= 10% of Total Supply (cannot increase, only decrease)
// Advertising Fund <= 5% of Total Supply (cannot increase, only decrease)
// Initial Liquidity Pool = 10% of Total Supply (can increase on demand)
// Initial circulation supply = 45% of initial Total Supply (can increase over demand)
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Safe math
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {c = a + b;require(c >= a);}
    function safeSub(uint a, uint b) public pure returns (uint c) {require(b <= a);c = a - b;}
    function safeMul(uint a, uint b) public pure returns (uint c) {c = a * b;require(a == 0 || c / a == b);}
    function safeDiv(uint a, uint b) public pure returns (uint c) {require(b > 0);c = a / b;}
}
// ----------------------------------------------------------------------------
contract BEP20Interface {
    // Get total supply of tokens.
    function totalSupply() public view returns (uint);
    // User's balance and allowance.
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    // Perform safe and authorized fund transfers from one user to another.
    function transfer(address to, uint tokens) public returns (bool success);
    // Approve spender to withdraw tokens from account.
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom (address from, address to, uint tokens) public returns (bool success);
    // Burn function.
    function burn(uint256 _value) public {_burn(msg.sender, _value);}
    function _burn(address sender, uint amount) public {}
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
// ----------------------------------------------------------------------------
// VulcanCoin Contract
// ----------------------------------------------------------------------------
contract VulcanCoin is BEP20Interface, SafeMath {
    //Name, symbol and decimals constants
    string public name;
    string public symbol;
    uint8 public decimals;
    // Burn addresses (from and to)
    address public burnTOaddress;
    address public burnFROMaddress;
    // Burn percentage (num/denom)
    uint public num;  // Burn percentage numerator
    uint public denom; // Burn percentage denominator
    // Total burned (TB)
    uint public _totalBurned;
    // Total supply (TS)
    uint public _totalSupply;
    mapping(address => uint) balances;
    mapping(address => mapping(address =>uint)) allowed;
    // ------------------------------------------------------------------------
    // Constructor variable and constant values
    // ------------------------------------------------------------------------
   constructor() public{
        // ------------------
        // NAME and Symbol 
        // ------------------
        name = "VulcanCoin";
        symbol = "VULCAN";
        // ------------------
        decimals = 18;
    // Burn addresses (from and to)
        burnTOaddress = 0x0000000000000000000000000000000000000000; // Burn TO address.
        burnFROMaddress = 0x7285f1E4Cf01B72848720e8c66cb20FA025BABDC; // Repository address for burning purposes only, containing locked 30% of Total Supply.
    // Burn percentage (num/denom)
        num = 1; // Burn percentage numerator
        denom = 1000; // Burn percentage denominator (num/denom=1/1000=0.001=0,1%)
    // Total supply (TS) definition and emission to tokenOwner
        _totalSupply = 21000000e18;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
     // Total burned (TB) tokens    
        balances[0x0000000000000000000000000000000000000000] = _totalBurned;
    }
    // ------------------------------------------------------------------------
    // Total supply function
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply - balances[address(0)];
    }
    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }
    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance (address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens` from the token owner's account.
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    // ------------------------------------------------------------------------
    // Token transference functionality
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
       
       if(tokens > 0){ // Transfer value has to be greater than zero
        if(balances[msg.sender] >= tokens){ // Sender has to own the tokens
        // Subtract tokens from owner account balance
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        // Add tokens to recipient account balance
        balances[to] = safeAdd(balances[to], tokens);
        // Do transfer the tokens
        emit Transfer(msg.sender, to, tokens);
         }
       }
       
        //// Burn 0.01% of the transaction from the burn supply /////
    
       // Initial Transfers from  deployment account do not burn tokens. Used to distribute initial supply into dev, adv, pool and burn accounts.
        if(msg.sender != burnFROMaddress){
         // Burn account has to have funds
         if(balances[burnFROMaddress] >= (tokens * num)/denom){
         _burn(burnTOaddress, (tokens * num)/denom);
         // Subtract burn amount from burn fund account
         balances[burnFROMaddress] = safeSub(balances[burnFROMaddress], (tokens * num)/denom);
         // Add burn amount to 0x0000000000000000000000000000000000000000 account
         balances[burnTOaddress] = safeAdd(balances[burnTOaddress], (tokens * num)/denom);
         emit Transfer(burnFROMaddress, burnTOaddress, (tokens * num)/denom);
         }
        }
        return true; 
    }
    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    // The calling account must already have sufficient tokens approved for spending from the `from` account and
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
       // Transfer tokens from(...) address to(...) adress
       if(tokens > 0){ // Transfer value has to be greater than zero
         if(balances[from] >= tokens){ // Sender has to own the tokens
         balances[from] = safeSub(balances[from], tokens);
         allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
         balances[to] = safeAdd(balances[to], tokens);   
         emit Transfer(from, to, tokens);
         }
       }
       
        ///// Burn 0.01% of the transaction from the burn supply /////
       
        if(msg.sender != burnFROMaddress){ // Initial Transfers from  deployment account do not burn tokens. Used to distribute initial supply into dev, adv, pool and burn accounts.
         // Burn account has to have funds
         if(balances[burnFROMaddress] >= (tokens * num)/denom){ // Burn as long as the burn address has enough tokens left
         _burn(burnTOaddress, (tokens * num)/denom);
         balances[burnFROMaddress] = safeSub(balances[burnFROMaddress], (tokens * num)/denom); // Subtract burn amount from burn fund account
         balances[burnTOaddress] = safeAdd(balances[burnTOaddress], (tokens * num)/denom); // Add burn amount to 0x0000000000000000000000000000000000000000 account
         emit Transfer(burnFROMaddress, burnTOaddress, (tokens * num)/denom);
         }
        }
        return true; 
    }
}
