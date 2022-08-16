```
  ,__ __                           _               _   
 /|  |  |  o                    \_|_)  o          | |  
  |  |  |    _|__|_  _   _  _     |        _  _   | |  
  |  |  |  |  |  |  |/  / |/ |   _|    |  / |/ |  |/_) 
  |  |  |_/|_/|_/|_/|__/  |  |_/(/\___/|_/  |  |_/| \_/

 Protecting your cold wallet so you don't get burnt.
```

Fully onchain verification and registry contract to store links between hot wallets and cold wallets.

The cold wallet never has to connect to any contract, the only requirement is to make a transfer with a specific value from the cold wallet to the hot wallet.

ps: This is a proof of concept, it was not deployed or tested in a production environment yet.

# Process

1. (Hot Wallet) User calls `getTransferValue` with the hot wallet address as parameter to get the required transfer value.

2. (Cold Wallet) User transfers the value from the cold wallet to the hot wallet.

3. (Hot Wallet) User calls `linkWallets` with the cold and hot wallet addresses, serialised transaction hash and v, r, s signature values from the transfer transaction.

4. (Hot Wallet) User calls `getWalletLinks` with the hot wallet address and receives array of cold wallets linked to it.


# Why?

There are a couple of existing solutions that allow linking a cold wallet to a hot wallet. Most of them rely on a signature from the cold wallet to prove ownership. Others require connecting the cold wallet to the contract and calling a method. And there are also offchain solutions that handle the verification elsewhere and store approved addresses on the contract.

## Problems of existing solutions

- Producing a signature requires technical knowledge that most people don't have.
- Connecting the cold wallet to a contract requires knowing / trusting the contract will not perform unwanted operations.
- Relying on offchain solutions goes against the sole propose of using blockchain.


# How is this different?

This method allows using the signature of a transfer transaction (EIP-1559 type 2) to prove ownership of a wallet. By sending the serialised transaction hash and v, r, s signature values to the contract we can ensure that the transaction data is correct (if any of the values is tampered the resulting public address will be different from the one provided).

# Ideas for improvements

Instead of storing the hotWallet<>coldWallets mapping in the contract state which could be tampered or lost when deploying a new contract, this contract could issue a Soulbound NFT containing the cold wallet address, and the verifiable data from the transaction (hash, v, r, s). This way, any project that would like to use MittenLink can simply fetch the hot wallet NFTs and `ecrecover(keccak256(hash, v, r, s))` to verify the cold wallet address.

# Related projects

- @wenew [HotWalletProxy](https://github.com/wenewlabs/public/blob/main/HotWalletProxy/HotWalletProxy.sol)
- @treemaru [TreeLogin](https://etherscan.io/address/0xD5aD600cAdf6dcDF63dEC463771b66E31c1C7aEB#code#F1#L1)
- @0xfoobar [DelegationRegistry](https://github.com/0xfoobar/nft-delegation/blob/main/src/DelegationRegistry.sol)