// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MemedToken is ERC20, Ownable {
    event TransfersEnabled();
    bool public transfersEnabled;

    constructor(string memory _name, string memory _ticker)
        ERC20(_name, _ticker)
        Ownable(msg.sender)
    {}

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _to, uint256 _amount) public onlyOwner {
        _burn(_to, _amount);
    }

    function enableTransfers() public onlyOwner {
        require(transfersEnabled == false, "Already enabled");
        transfersEnabled = true;
        emit TransfersEnabled();
    }

    function _update( 
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(
            transfersEnabled || from == address(0) || to == address(0),
            "Transfers are restricted"
        );
        super._update(from, to, amount);
    }
}
