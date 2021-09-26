// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

  contract RewardToken is AccessControl, ERC20Capped,ERC20Permit, ERC20Votes {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

  //Amount that will be minted on next mint call
  uint256 private _nextAllowedMint;
  // Timestamp of when minting may be allowed;
  uint256 private _mintingAllowedAfter;
  // Minimum time required between each mints
  uint256 private _minimumTimeBetweenMints;
  //  Amount of mints left 
  uint256 private _mintCount;
  //  Total amount of tokens left to be minted
  uint256 private _mintAmountleft;


    /**
     * @notice Construct a new Treasure token
     * @notice implements ERC20 standards and ERC20cappped standards
     * @param name_ Name of the token created from ERC20 standards
     * @param symbol_ Symbol of the token created from ERC20 standards
     * @param cap_ The total max supply of the token
     * @param initialSupply_ The total amount that is accessible on token deployment
     * @param mintingAllowedAfter_ Timestamp of when minting may be allowed;
     **/

  constructor(
      string memory name_, 
      string memory symbol_, 
      uint256 cap_, 
      uint256 initialSupply_, 
      uint256 mintingAllowedAfter_
    ) 
    ERC20(name_,symbol_) 
    ERC20Capped(cap_) 
    ERC20Permit(name_)
    {
      require(mintingAllowedAfter_ >= block.timestamp, "Token::constructor: minting can only start after token is deployed");

      // Setting up roles
      _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
      _setupRole(MINTER_ROLE, _msgSender());
      _setupRole(BURNER_ROLE, _msgSender());

        ERC20._mint(_msgSender(), initialSupply_);
        _mintingAllowedAfter = mintingAllowedAfter_;
        _minimumTimeBetweenMints= 1 minutes * 5;  
        _nextAllowedMint = 200 * (10**uint256(18));
        _mintCount = 3;
        _mintAmountleft = 600 * (10**uint256(18));
    }

    /**
     * @return Returns the count of mints that is remaining 
     */
   function remainingMints() 
      public 
      view 
      returns(uint256) 
    {
          return _mintCount;
    }

    /**
     * @return Returns the Total amounts Tokens that is yet to be minted  
     */
    function mintAmountleft() 
      public 
      view 
      returns(uint256) 
    {
          return _mintAmountleft;
    }

    /**
     * @return Returns the Total amounts Tokens that is allowed to be minted  next
     */
    function nextAllowedMint() 
        public 
        view 
        returns(uint256) 
    {
          return _nextAllowedMint;
    }

    /**
     * @return Returns the Timestamp of when minting may be allowed  
     */
    function mintingAllowedAfter() 
        public 
        view 
        returns(uint256) 
      {
          return _mintingAllowedAfter;
      }

    /**
     * @return Returns the Timestamp of when minting may be allowed  
     */
    function minimumTimeBetweenMints()
        public 
        view 
        returns(uint256) 
      {
            return _minimumTimeBetweenMints;
      }

    /**
     * @notice Mint new tokens, can only be accessed by owner
     * @param account The address of the destination account
     */
    function mint(
        address account
        ) 
      public 
      virtual 
      onlyRole(MINTER_ROLE)
      {
          require(_mintCount > 0, 'Token: All Tokens has been minted');
          require(block.timestamp > _mintingAllowedAfter,  "Token: Minting not permited yet.");

         // Mint tokens
          uint256 amount = _nextAllowedMint;
          _mint(account,amount);

        //  Record the mint 
         _mintingAllowedAfter = block.timestamp + _minimumTimeBetweenMints;
         _mintCount -= 1;
         _mintAmountleft -= amount;
         if (mintAmountleft() == 0 ){
            _nextAllowedMint = 0;
            _mintingAllowedAfter= 0;
          }
    }

    /**
     * @notice Destroys `amount` tokens from the caller.
     * @param amount The amount of tokens to be  destroyed
     */
    function burn(uint256 amount) public virtual onlyRole(BURNER_ROLE) {
        _burn(_msgSender(), amount);
    }

    /**
     * @notice Destroys `amount` tokens from `account`, deducting from the caller's. 
     * @notice Caller must have allowance from owners account 
     * @param account The address of tokens will be destroyed from
     * @param amount Tamount of tokens to be  destroyed from that account
     */
    function burnFrom(address account, uint256 amount) public virtual  onlyRole(BURNER_ROLE) {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }

    /**
     * @notice Mint new tokens
     * @param account The address of the destination account
     * @param amount The address of the destination account
     */
    function _mint(
        address account, 
        uint256 amount) 
      internal 
      virtual 
      override(ERC20,ERC20Capped,ERC20Votes)
    {
        ERC20Capped._mint(account, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
   
    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

}

