Interoperability is a broad term that encompasses many different kinds of interactions between blockchains. Most of the commonly used definitions are quite reasonable, but they are often for very specific use cases, and they all have different safety/liveliness trade-offs. We will discuss some of the biggest forms of "interoperability" and 

For the purposes of discussion, we define interoperability as such:

> Interoperability is the ability to move digital assets, and data, from one blockchain to another.

This definition is intentionally general; all reasonable forms of inter-blockchain communication/interaction are captured by this definition. Using this definition, we can take a look at some of the approaches available today and discuss their advantages and disadvantages.

## Atomic Swaps (Hashed Timelock Contracts)

Atomic swaps offer users the ability to swap tokens on different blockchains in a way that is atomic. Often, this is achieved using a technique called Hashed Timelock Contracts (HTLCs). Atomic swaps allow Alice can send ETH to Bob, and Bob can send BTC to Alice, in a way that is trustless and completely decentralised.

However, the definition of atomic is very important to understand precisely. An atomic swap is one that happens "in full, or not at all". At first glance, this seems like a reasonable property. It means that if Alice successfully sends ETH to Bob, she can be guaranteed to receive BTC from Bob. At second glance, we realise the "or not at all" causes serious problems that render atomic swaps useless for most real-world applications.

At any point, Alice or Bob can stop participating in the swap (whether on purpose, or by accident). If the swap has not yet completed, both parties will get their assets refunded (albeit with a delay of 24 hours). This is all well and good, but the swap *is not guaranteed* to actually happen. This is called the "free option problem". Both Alice and Bob are incentivised to move as slowly as possible, and if the market moves against them at any point, they can simply stop participating and cancel the swap.

| Advantages | |
|---|---|
| Simple | Compared to other solutions, atomic swaps are reasonable simple to understand and implement. |
| Two parties | The only parties involved are the parties swapping assets. This means there are no safety/liveliness considerations beyond the two blockchains being used. |

| Disadvantages | |
|---|---|
| Slow | Atomic swaps required multiple transactions on both blockchains and require large timelock windows of up to 24 hours. |
| Free option problem | Atomic swaps cannot be forced to happen. Participants have an incentive to be slow and cancel the swap if it becomes unprofitable. |
| Interactive | The need for multiple transactions on both blockchains, with large timelock windows, means that users need to stay logged into the system, or download specialised background daemons. |
| Not general purpose | No information is actually being transferred between blockchains. This means atomic swaps cannot be used for lending/borrowing/collateralisation/etc. |

## Native Interoperability (Polkadot/Cosmos/etc.)

Native interoperability is the most integrated form of interoperability: it is built directly into the rules of the blockchain and is a fundamental part of its definition. For example: both Polkadot and Cosmos define interoperability rules to which "parachains" and "zones" must adhere to respectively.

This has many advantages: safety, liveliness, speed, and flexibility. All of these come from the fact that interoperability is native part of the blockchain itself, and engaging with interoperability features is no different from engaging with the actual blockchain.

However, there is one major disadvantage: compatibility. Existing blockchains are already well established and do not implement these rules. Ethereum, Bitcoin, and most other blockchains are not "parachains" or "zones" and in many cases are unlikely to ever migrate (such a migration would be drastic and complex). To interoperate with these existing blockchains, blockchains like Polkadot and Cosmos must rely on other forms of interoperability.

| Advantages | |
|---|---|
| Safety/Liveliness | Safety/liveliness properties of interoperability are the same as that of the blockchain itself and there is no reliance on additional systems. |
| Speed | Built-in support means that interoperability happens at the same speed as normal transactions in the blockchain.
| Flexible | Built-in support means that interoperability can be defined in whichever way is most appropriate. Different types of interoperability can also be defined for different situations. |
| General purpose | This kind of interoperability can be used to move digital assets and data. This means it can be used for any kind of application. |

| Disadvantages | |
|---|---|
| Incompatible | Interoperability with existing blockchains (or new blockchains that do not integrate) must use a different approach. |

## Synthetics

Synthetics are arguably not a real form of interoperability, as the goal is typically not to share assets/data between blockchains. However, they are interesting, and some new forms of interoperability utilise synthetic-like behaviour.

A synthetic is a simulation of an asset from another blockchain (or from the real-world). It is called a synthetic because it is not necessarily backed by the actual asset being simulated: you cannot always turn a synthetic into the actual asset, nor use the actual asset to create the synthetic.

In general, some set of rules are put in place to that economic activity forces the price of the synthetic asset to be as close as possible to the actuall asset.

| Advantages | |
|---|---|
| Speed | No transactions are needed on the other blockchain. Synthetics can be created/used/destroyed at the same speed as normal transactions on the blockchain.
| Liquidity | The liquidity of a synthetic is not necessarily limited by the liquidity of the actual asset. |

| Disadvantages | |
|---|---|
| Synthetic | By definition, a synthetic is not necessarily backed by the actual asset. This means that liquidity cannot necessarily be shared between blockchains. |
| Not general purpose | Only the price of the actual assets is able to be simulated by the synthetic. Other properties are lost, and this technique makes no sense for plain data. |

## Multi-sigs

Multi-signatures are one of the simplest ways to achieve general purpose interoperability between blockchains that do not natively support interoperability. A group of signatories observe an event on one blockchain, collectively sign a message attesting to that event, and publish the collective signature to a second blockchain. In this way, the second blockchain can trust that this event happened as much as it can trust the group of signatories.

One of the nice things about multi-signatures is that we can define them to be "M-out-of-N". This means that not everyone has to attest to the event for a valid signature to be produced. However, on Bitcoin, N is limited to 20 (in practice multi-signatures of this size are not mined quickly).

| Advantages | |
|---|---|
| Simple | Compared to other solutions, multi-signatures are reasonable simple to understand and implement. |
| General purpose | This kind of interoperability can be used to move digital assets and data. This means it can be used for any kind of application. |

| Disadvantages | |
|---|---|
| Expensive | Publishing a collective signature requires publishing multiple signatures which results in a lot of bytes being posted on-chain. |
| Centralised | The upper bound that exists explicitly on some blockchains and implicity on other blockchains (due to expense) puts a limit of how decentralised multi-signatures can be. |