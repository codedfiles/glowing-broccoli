Gateways are special “secret contracts” built into RenVM that define interoperability bridges between blockchains. Users transfer assets to the gateway on one blockchain, and RenVM mints a tokenised representation of those assets on another blockchain. The user can also attach application-specific data, allowing the minting transaction to immediately invoke smart contract logic (i.e. the transaction that mints the tokenised representation will immediately send those tokens to a smart contract for swapping/lending/collateral/etc.).​

## Support

Currently RenVM supports three gateways:

- `BTCEthereum` for sending BTC to Ethereum, and back again.
- `BCHEthereum` for sending BCH to Ethereum, and back again.
- `ZECEthereum` for sending ZEC to Ethereum, and back again.

For the rest of this section, we will talk about the `BTCEthereum` gateway, because the `BCHEthereum` and `ZECEthereum` gateways function in the exact same way. In fact, any Bitcoin-fork interoperating with any Ethereum-fork will function in the exact same way.

For information about the design of other gateways, checkout:

- [Gateways for Matic]()
- [Gateways for Ripple]()
- [Gateways for Binance]()

## Overview​

Interoperability between Bitcoin and Ethereum is realised through a tokenised ERC20 representation of BTC, known as **renBTC** (it is called zBTC on Testnet/Chaosnet for easy differentiation). When someone transfers BTC to RenVM it is considered locked, and RenVM will mint the respective amount of renBTC to the specified Ethereum address. Similarly, when someone burns renBTC, RenVM will release the respective amount of BTC by transferring it to the specified Bitcoin address. This is known as locking/releasing and minting/burning.

This is implemented in a permissionless, trustless, and decentralised way by using the RZL sMPC algorithm to generate, operate, and rotate ECDSA private keys (see [Execution]()) in secret. These ECDSA private keys are used to receive BTC, transfer BTC, and authorise the minting of renBTC. The RZL sMPC algorithm guarantees that the ECDSA private keys are never seen by anyone, and cannot be used without consensus from the network. This is why gateways are considered to be “secret contracts”. Unless someone can attack 1/3rd+ of the Darknodes, the safety and liveliness guarantees of RenVM cannot be broken. See [Execution]() for more information about RZL sMPC.

In this way, you can think of RenVM as a permissionless, trustless, and decentralised BTC custodian that maintains a fungible 1:1 backed ERC20 representation of BTC.​

## Definitions

- **origin** blockchains those from which an asset originates. For example, Bitcoin is the origin blockchain for BTC, and Ethereum is the origin blockchain for ETH. 
- **host** blockchains are those on which an asset has been tokenised. For example, Ethereum is the host blockchain for the renBTC ERC20 token.
- **locked** assets are those that are currently owned by one of the gateway ECDSA private keys. For example, BTC that has been sent to a Bitcoin gateway and can only be released by burning renBTC can be referred to as locked BTC.
- **tokenised** assets are those that have been minted on a host blockchain, and are backed by locked assets on the origin blockchain. For example, renBTC is a tokenised representation of BTC. Minting tokenised assets requires a valid and unique minting signatures.
- **minting signatures** authorise the minting of an amount of renBTC to a specific Ethereum address. These are produced by the Darknodes running the relevant shards in response to BTC being transferred to a gateway script.
- **gateways** are a collection of different components that, together, enable interoperability between a pair of blockchains.
- **gateway contracts** are the Ethereum smart contracts that check the validity and uniqueness of minting signatures before minting tokenised assets. For example, the `BTCGateway` contract is the gateway contract for renBTC.
- **gateway scripts** (and their associated gateway script addresses) are specifically built Bitcoin scripts. BTC sent to these scripts will result in the minting of renBTC.
- **gateway private keys** (and their associated gateway public keys) are the ECDSA keys generated, used, and rotated by the Darknodes running the relevant shard. These keys are the only keys able to spend BTC from gateway scripts, or produce valid minting signatures for renBTC.

## Locking and Minting BTC

Locking and minting is the process by which users can send BTC from the Bitcoin blockchain to the Ethereum blockchain. See [Gateway Safety and Fees]() for more information about the fees that must be paid to RenVM.​

First, the user must generate a valid gateway script. The user can then transfer BTC to the gateway script, wait for 6 confirmations, and then call `ren_submitTx` on one (or many) of the Darknodes. This notifies them about the existence of the gateway script, and the UTXO that transfers BTC to it.

A valid gateway script must be built from the following template:

```
ghash
OP_DROP
OP_DUP
OP_HASH160
pub_key_hash160
OP_EQUALVERIFY
OP_CHECKSIG
```

- `ghash` is the `keccak256(..)` hash of `encode(phash, token, to, n)`, where `encode(..)` is the Ethereum ABI encoding function (as implemented by the Solidity `abi.encode(..) returns (bytes)` function).
- `pub_key_hash` is the `hash160(..)` of the gateway public key. This changes every epoch (see [Epochs](https://github.com/renproject/ren/wiki/Gateways#Epochs)).
- `phash` is the `keccak256(encode(..))` hash of arbitrary application-specific data, encoded using the Ethereum ABI encoding function. By including `phash` in the gateway script, the application-specific data is bound to the script. All BTC transferred to the script will be minted on Ethereum in association with this `phash`, allowing smart contracts to validate the application-specific data.
- `token` is the Ethereum address of the token being minted. In the case of BTC, this is the Ethereum address of renBTC. This is the same for all `BTC2Ethereum` gateway scripts.
- `to` is the Ethereum address that will receive the renBTC. This must be the `msg.sender` that calls the `mint` function on the `BTCGateway` gateway contract.  
- `n` is nonce made up of 32 random bytes. By including `n` in the gateway script, the script can have a unique address even when all other details are identical.

To call `ren_submitTx`, the user must send a RenVM transaction. The RenVM transaction must contain:

- the `phash`,
- the application-specific data that is used to compute `phash`,
- the `token` address,
- the `to` address,
- the `n` nonce, and
- the UTXO that has transferred BTC to the gateway script.

The Darknodes will gossip the RenVM transaction, verify its contents, use it to independently build the gateway script, check the validity of the UTXO, check the uniqueness of the UTXO, and check that the UTXO has at least 6 confirmations. Once the RenVM transaction has been fully verified, RenVM will add the transaction to the transaction pool for consensus and execution.

​The user can poll `ren_queryTx`, and once execution has finished it will return:

- the `rsv` minting signature that authorises the minting of renBTC,
- the `nhash` which is the `keccak256(..)` hash of `n` combined with the UTXO, and
- the `amount` of renBTC that is authorised for minting. This is equal to the amount in the UTXO.

After these values are returned, the user can submit all of the input/out data to Ethereum to mint the renBTC.

See [RPCs]() for a complete description of the JSON-RPC 2.0 API and [Transactions]() for the JSON specification of RenVM transaction. See [RenJS]() and [GatewayJS]() documentation for examples using JavaScript.​

## Burning and Releasing BTC

At any point, users can burn an arbitrary amount of renBTC. At the same time, they must specify a Bitcoin address. The Darknodes powering RenVM will eventually observe this burn event on Ethereum, and after 12 confirmations will create a RenVM transaction to release the respective amount of BTC to the specified Bitcoin address. See [Gateway Safety and Fees]() for more information about the fees that must be paid to RenVM.

The user does not need to take any action other than burning renBTC and specifying their Bitcoin address. RenVM will automatically see the burn event, generate a signed Bitcoin transaction to release BTC to the specified Bitcoin address, and submit the Bitcoin transaction.​

RenVM engages its [consensus algorithm]() to agree on the order in which to process burns, the UTXOs to use when building the Bitcoin transaction, and the amount of SATs to use for the Bitcoin transaction fees. To optimise these fees, RenVM batches multiple burns into a single Bitcoin transaction with multiple outputs. Any left over BTC is refunded to the gateway public key. RenVM will favour using UTXOs in gateway scripts over UTXOs in the gateway public key.

See the [GatewayJS documentation]() for examples of how to burn renBTC using JavaScript.

## Epochs

At the end of every epoch, the gateway private keys must be rotated. Darknodes eventually become inactive and deregister withdraw their bond (at epoch periodicity. It is required for safety that no deregistered Darknode has a Shamir’s secret shares for an active gateway private key. By rotating the key at the end of every epoch, rotation aligns exactly with the (de)registration of Darknodes (see [Darknode Registry]()), and changing which Darknodes are responsible for shards (see [Sharding]()).

The Darknodes responsible for the shard at epoch `E` will generate a new ECDSA private key using the RZL sMPC algorithm (no Darknodes ever see the private key). This is done is such a way that the new ECDSA public key is known, but the respective Shamir’s secret shares are encrypted for the Darknodes at epoch `E+1`. The Darknodes at `E` combine all UTXOs into a single transaction that forwards all BTC to the newly generated ECDSA public key.

The ECDSA public key and encrypted Shamir’s secret shares are stored as state in the base block (see [Consensus]()). The Darknodes at epoch `E+1` get the public key and their respective share of the private key from the base block, and the rotation is finished. For the duration of epoch `E+1`, the Darknodes at epoch `E` will continue to support gateway scripts built at epoch `E`, and will transform all relevant RenVM transactions for `E+1`.

## Fees
​
### Minting Fee

There is a minting fee, `fee_m`, that is initially set to 0%. This fee is sent to the [Darknode Payments]() smart contract during the minting transaction. It is initially set to 0% to encourage the locking/minting of renBTC. The minting fee increases as the total value of locked BTC increases (see [Gateway Safety and Fees]()).

### Burning Fee

There is a burning fee, `fee_b`, initially set to 0.1%. This fee is sent to the [Darknode Payments]() smart contract during the burning transaction. It is applied in addition to the underlying Bitcoin transaction fee. The burning fee decreases as the total value of locked BTC increases (see [Gateway Safety and Fees]()).

### Continuous Fees

There is a continuous fee, `fee_c`, initially set to approximately 1% per annum, at a compounding rate of 0.000000031639% per second (see [Gateway Safety and Fees]()).​

Continuous fees are implemented by slowly inflating the ratio, `r`, between BTC and renBTC. At time `t`, locking `n` BTC will result in the minting of `n * r` renBTC, where `r = base + (1+fee_c)^ t`. When `fee_c` is changed, `base` is set to the current value of `r` (which is initially set to zero). Similarly, at time `t` burning `m` renBTC will result in the releasing of `m/r` BTC.

Two ERC20 interfaces will exist for renBTC: absolute and relative. The **absolute** ERC20 interface, commonly referred to as renBTC, accepts/returns the “true” balances (that is, without adjustments for continuous fees). From one moment to the next, unless transfers happens, balances do not change with time. This should be unsurprising, and is exactly how most ERC20s are implemented. The **relative** ERC20 interface accepts/returns values in BTC. It uses the same underlying balances as renBTC, but modifies them to account for continuous fees. This is useful in UIs.

### Governance

​All fees are subject to governance. This allows them to be set in response to market conditions. For example, eventually having a 0% minting fee to encourage the minting of renBTC will no longer be necessary. It is also desirable to have the continuous fee at a rate that is (a) competitive compared to other custodians and (b) less than the interest that can be earned on lending platforms.

During Mainnet SubZero/Zero, governances will be controlled by the Ren team. By Mainnet One, governances will he controlled by the Darknodes, using an Ethereum smart contract to vote.

## Example

This examples involves two users, Alice and Bob. Alice will use the `BTCEthereum` gateway to send BTC from Bitcoin to Ethereum. Then, Alice will transfer the tokenised BTC to Bob. Lastly, Bob will send the BTC from Ethereum back to Bitcoin.

### Lock and Mint

To send BTC from Bitcoin to Ethereum, Alice must first build a Bitcoin gateway script. Alice will be doing a simple lock/mint without directly invoking smart contract logic, so she will not need any kind of application-specific data (she is not interacting with an application).

1. Alice sets `phash` to `keccak(0x00)`.
2. Alice sets `token` to the `RenBTC` ERC20 smart contract address.
3. Alice sets `to` to her Ethereum address.
4. Alice sets `n` to 32 randomly generated bytes.
5. Alice sets `ghash` to `keccak(encode(phash, token, to, n))`.
6. Alice sets `pub_key_hash` to the `hash160(..)` of the Bitcoin gateway public key for the `BTCEthereum` gateway (this public key is publicly available, and can be queried by calling the `ren_queryEpoch` RPC on any Darknode).
7. Alice builds her Bitcoin gateway script using `ghash` and `pub_key_hash`.

Now that Alice has her Bitcoin gateway script (and its associated Bitcoin address), she can begin sending BTC to Ethereum.

1. Alice sends 0.42 BTC to the Bitcoin gateway script address.
2. Alice waits until her transaction has 6 confirmations.
3. Alice selects multiple Darknodes and calls the `ren_submitTx` RPC.
4. Alice selects multiple Darknodes and polls the `ren_queryTx` RPC until she sees that the RenVM transaction she submitted in (3) has been executed.
5. Alice takes the `rsv` in the RenVM transaction returned from (4) and uses it to submit a transaction to Ethereum that calls the `lock` function on the `BTCGateway` smart contract.  
6. Alice calls the `balanceOf` function on the `RenBTC` smart contract and sees that her renBTC balance has increased. She is now the proud owner of BTC on Ethereum!

Alice now has 0.42 renBTC. She can use this like a standard ERC20, swapping it on DEXs, lending it, using it as collateral, and everything else that is possible in the DeFi ecosystem. For now, she will simply transfer her 0.42 renBTC to Bob.

### Transfer

Transferring BTC on the Ethereum blockchain is simple. After locking/minting, Alice has 0.42 renBTC. For all intents and purposes, renBTC is a standard ERC20 and can be transferred, approved, etc. similarly to other ERC20s.

1. Alice submits a transaction to Ethereum that calls the `transfer` function on the `RenBTC` ERC20 smart contract. This transfer sends the renBTC to Bob. No fees are taken during this step.
2. Bob calls the `balanceOf` function on the `RenBTC` smart contract and sees that his renBTC balance has increased. He is now the proud owner of BTC on Ethereum!

Bob now has 0.42 renBTC. Like Alice, he can use this like a standard ERC20 in the DeFi ecosystem. However, Bob has decided that he wants to send some of this BTC from Ethereum back to Bitcoin.

### Burn and Release

Burning renBTC on Ethereum is seen by RenVM. In response, it releases BTC to the Bitcoin address specified in the burn.

1. After one minute, Bob submits a transaction to Ethereum that calls the `burn` function on the `BTCGateway` smart contract. He specifies that he wants to burn 0.4 renBTC (keeping 0.02 renBTC). He also specifies his Bitcoin address.
2. Bob polls Bitcoin to check his BTC balance. After 30 Ethereum confirmations, he sees that there is a new UTXO paid to his Bitcon address for 0.39959992408 BTC (0.1% burning fee, 0.0000001898% continuous fee for 60 seconds, and 10000 SATs in Bitcoin transaction fees).

This completes the minting, transferring, and burning of BTC to/from Ethereum. At no point was a trusted or centralised party required, and at no point was permission required.

