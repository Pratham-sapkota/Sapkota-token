// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract SapkotaToken is ERC20Capped, ERC20Burnable {
    //ERC20Capped uses ERC20 so we are using ERC20Capped
    //declare owner variable
    address payable public owner;
    uint256 public blockReward;

    //cap determines the max supply , if it exceed the cap value then error is thrown
    constructor(
        uint256 cap,
        uint256 reward
    ) ERC20("SapkotaToken", "PS") ERC20Capped(cap * (10 ** decimals())) {
        owner = payable(msg.sender);
        //it gives the initial supply of token for the owner
        _mint(owner, 70000000 * (10 ** decimals()));
        blockReward = reward * (10 ** decimals());
    }

    //since derived contract must override _mint
    function _mint(
        address account,
        uint256 amount
    ) internal override(ERC20, ERC20Capped) {
        require(
            ERC20.totalSupply() + amount <= cap(),
            "ERC20Capped: cap exceeded"
        );
        super._mint(account, amount);
    }

    //function to reward mines who addsblock to the blockchain.
    // It should be called internally show used internal.
    function _mintMinerReward() internal {
        // block.coinbase is miner's address
        _mint(block.coinbase, blockReward);
    }

    // Hook that is called before any transfer of tokens. This includes minting and burning.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        if (
            from != address(0) &&
            to != block.coinbase &&
            block.coinbase != address(0)
        ) {
            _mintMinerReward();
        }
        super._beforeTokenTransfer(from, to, value);
    }

    //if we want to change block reward later on
    function setBlockReward(uint256 reward) public onlyOwner {
        blockReward = reward * (10 ** decimals());
    }

    //if you want to destroy the contract in future
    // function destroy() public onlyOwner{
    //     selfdestruct(owner);
    // }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _; //placeholder for rest of the function
    }
}
