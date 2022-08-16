// SPDX-License-Identifier: GNU GPLv3

pragma solidity ^0.8.4;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./RLPReader.sol";

/** 
* @title A registry contract to store links between hot wallets and cold wallets
* @author tomasmcm
* @dev currently only supports EIP-1559 type 2 transfer transactions
*/

contract MittenLink {
	using RLPReader for RLPReader.RLPItem;
	using RLPReader for bytes;
	using EnumerableSet for EnumerableSet.AddressSet;

	/// @notice Main mapping to store array of cold wallets connected to hot wallet
	mapping(address => EnumerableSet.AddressSet) internal walletLinks;

	/// @notice minTransfer and maxTransfer are used as bounds to determine value for transfer
	uint256 constant internal minTransfer = 5000000000000; // wei
	uint256 constant internal maxTransfer = 500000000000000; // wei
	/// @notice multiplier allows converting address to transfer value
	/// 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF / (maxTransfer - minTransfer)
	uint256 constant internal multiplier = 1461501637330902918203684832716283019655932542975 / (maxTransfer - minTransfer);

	/// @notice EIP-1559 type 2 header
	bytes constant internal HEADER = hex"02";
	address constant internal MAX = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
	address constant internal MIN = 0x0000000000000000000000000000000000000000;

	/** -----------  WRITE ----------- */

	/**
	* @notice Verify and link a cold wallet to a hot wallet
	* @param coldWallet The cold wallet where the transfer was sent from and will be used as value in the registry
	* @param hotWallet The hot wallet that received the transfer and will be used as key in the registry
	* @param rawHash Raw transaction data
	* @param v ECDSA signature v param
	* @param r ECDSA signature r param
	* @param s ECDSA signature s param
	*/
	function linkWallets(
		address coldWallet,
		address hotWallet,
		bytes calldata rawHash,
		uint8 v,
		bytes32 r,
		bytes32 s
	)
	external {
		require(
			coldWallet != hotWallet &&
			coldWallet != MAX &&
			hotWallet != MAX &&
			coldWallet != MIN &&
			hotWallet != MIN,
			"coldWallet and hotWallet need to be different"
		);

		RLPReader.RLPItem[] memory ls = hashToRLP(rawHash).toRlpItem().toList();

		address rlpFrom = ecrecover(keccak256(rawHash), v, r, s);
		require(rlpFrom == coldWallet, "Signature does not match coldWallet");

		address rlpTo = ls[5].toAddress();
		require (rlpTo == hotWallet, "Signature does not match hotWallet");

		uint256 rlpValue = ls[6].toUint();
		require (rlpValue == this.getTransferValue(rlpTo), "Value does not match required");

		require (!walletLinks[rlpTo].contains(rlpFrom), "Wallet link already saved");

		walletLinks[rlpTo].add(rlpFrom);
	}

	/** -----------  READ ----------- */

	/**
	* @notice Returns the value that needs to be transfered to the hot wallet for verification
	* @param hotWallet The address of the hot wallet that will receive the transfer
	* @return uint256 Value for the transfer in wei rounded to 1e10
	*/
	function getTransferValue(address hotWallet)
	external
	pure
	returns (uint256)
	{
		uint256 hotWalletValue = uint256(uint160(hotWallet));
		return ((hotWalletValue / multiplier) + minTransfer) / 10000000000 * 10000000000;
	}

	/**
	* @notice Returns an array of cold wallets linked to a hot wallet
	* @param hotWallet The address of the hot wallet
	* @return addresses Array of cold wallets linked to a hot wallet
	*/
	function getWalletLinks(address hotWallet)
	external
	view
	returns (address[] memory) {
		return walletLinks[hotWallet].values();
	}

	/** -----------  PRIVATE ----------- */

	/**
	* @notice Returns rlp hash from raw transaction hash
	* @param hash The raw hash with the transaction data
	* @return rlp Hash encoded with RLP
	*/
	function hashToRLP(bytes calldata hash)
	private
	pure
	returns (bytes memory rlp){
		rlp = new bytes(hash.length - 1);
		for (uint i = 1; i < hash.length; i++) {
			rlp[i - 1] = hash[i];
		}
	}
}