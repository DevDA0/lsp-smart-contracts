// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.4;

// interfaces
import {ILSP7Mintable} from "../presets/ILSP7Mintable.sol";

// modules
import {LSP7DigitalAsset} from "../LSP7DigitalAsset.sol";

contract WLYX7 is LSP7DigitalAsset, ILSP7Mintable {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 lsp4TokenType_,
        bool isNonDivisible_
    )
        LSP7DigitalAsset(
            name_,
            symbol_,
            address(0),
            lsp4TokenType_,
            isNonDivisible_
        )
    {}

    modifier onlyThis() {
        require(msg.sender == address(this), "Only the contract itself can call this.");
        _;
    }

    function mint(
        address to,
        uint256 amount,
        bool force,
        bytes memory data
    ) public virtual onlyThis {
        _mint(to, amount, force, data);
    }

    /// @dev Fallback, `msg.value` of LYX sent to this contract grants caller account a matching increase in WLYX7 token balance.
    receive() external payable override {
        mint(msg.sender, msg.value, false, "");
    }

    /// @dev `msg.value` of LYX sent to this contract grants caller account a matching increase in WLYX7 token balance.
    function deposit() external payable {
        mint(msg.sender, msg.value, false, "");
    }

    /// @dev `msg.value` of LYX sent to this contract grants `to` account a matching increase in WLYX7 token balance.
    function depositTo(address to) external payable {
        mint(to, msg.value, false, "");
    }

    /// @dev Burn `value` WLYX7 token from caller account and withdraw matching LYX to the same.
    /// Requirements:
    ///   - caller account must have at least `value` balance of WLYX7 token.
    function withdraw(uint256 value) external {
        uint256 balance = balanceOf(msg.sender);
        require(balance >= value, "WLYX: burn amount exceeds balance");
        _burn(msg.sender, balance - value, "");

        // _transferLukso(msg.sender, value);
        (bool success, ) = msg.sender.call{value: value}("");
        require(success, "WLYX: LYX transfer failed");
    }

    /// @dev Burn `value` WLYX7 token from caller account and withdraw matching LYX to account (`to`).
    /// Requirements:
    ///   - caller account must have at least `value` balance of WLYX7 token.
    function withdrawTo(address payable to, uint256 value) external {
        uint256 balance = balanceOf(msg.sender);
        require(balance >= value, "WLYX: burn amount exceeds balance");
        _burn(msg.sender, balance - value, "");

        // _transferLukso(to, value);
        (bool success, ) = to.call{value: value}("");
        require(success, "WLYX: LYX transfer failed");
    }
}