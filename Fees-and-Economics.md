

# Fees and Economics

RenVM assumes that Darknodes are rational, and will attempt to maximise their own profit. As such, that there must be an economic incentive for the Darknodes to power RenVM, because contributing CPU cycles, disk space, and network bandwidth has a non-zero cost. Furthermore, the Darknodes are required to bond 100000 REN, which has a non-zero opportunity cost.

## Definitions

- The *minting fee* is a percentage fee charged when minting an asset to a host chain.

- The *burning fee* is a percentage fee charged when burning an asset from a host chain.

- The *continuous fee* is a percentage fee charged per-second while an asset is on a host chain.

- `L` is the total value of all locked assets. Locked assets are those custodies by RenVM while a representation of that asset exists in a host chain. 

- `R` is the total value of all REN bonded to RenVM by the Darknides. Darknodes must bond 100000 REN to be admitted into RenVM.

## Minting and Burning Fees

RenVM incentivises Darknodes by charging users a small fee every time they submit a cross-chain transaction to RenVM. This fee is marked in the asset that is involved in the cross-chain transaction. For example, sending BTC from Bitcoin to Ethereum will involve a small fee that is marked in BTC. All shards charge the same minting and burning fee, but the minting and burning fees can be different for different assets.

At genesis, the minting and burning fee are both set to 0.1%. However, these fees are adjustable by a collective Darknode vote. Darknodes continuously engage in voting to adjust the minting and burning fees such that `L < R/3`. Darknodes vote to adjust the fees in accordance with their own valuation of their REN bond, whether they base this on the market value, or an internal model. Increasing the minting and burning fees will result in the delayed increase of `R`, assuming that it is not increased excessively (discouraging use).

## Continuous Fees

The continuous fee is another, more powerful, mechanism for guaranteeing the `L < R/3` constraint. The continuous fee is a per-second compounding fee charged to those holding cross-chain assets. For example, a `1%` per-annum continuous fee would be represented as a `0.0000000315523%` per-second compounding fee. A user that locks and mints `1 BTC` to Ethereum, and then holds it there for a year, would be able to burn and release `0.99 BTC`. 

By default, the continuous fee is set to `0%`. Similarly to minting and burning fees, the Darknodes continuously engage in voting to adjust the continuous fee. Generally, Darknodes are encouraged to guarantee `L < R/3` by adjusting minting and burning fees. However, depending on market conditions, it can be necessary to strongly incentivise lowering of `L` (as oppose to the raising of `R`). To do this, Darknodes must vote to raise the continuous fee until users begin burning and releasing their assets from host chains back to origin chains.

## Safety

Fees are directly related to the safety of RenVM. The only utility of REN is for bonding Darknodes to RenVM; an unbonded Darknode will be ignored by network participants. As such, the value of REN is derived solely from the fees earned by RenVM, and speculative trading. The value of REN is important, because this determines whether or not it is profitable to attempt an attack against RenVM.

When `L > R/3`, an attack against RenVM is theoretically profitable. Adjusting the minting and burning fees allows RenVM to raise `R`, and adjusting the continuous fee allows RenVM to lower `L`. Together, these economic drivers allow RenVM to enforce the `L < R/3` constraint.

It is possible that an adversary (or volatile market conditions) could cause the spot price of REN to drop, irrespective of the fees earned by Darknodes. However, the spot price of REN is not especially relevant. Consider the most extreme version of this scenario, where an adversary drives the spot price of REN to zero. No rational Darknode that is earning yield from its REN bond would sell the bond for nothing; it is more profitable to continue operating honestly to earn fees. In fact, at zero, the yield for REN is infinite.

Because there is no liquidation mechanism in RenVM, the spot price of REN does not matter. Only the price at which Darknodes are willing to bribed to behave maliciously matters, and this is set by their own valuation of REN and their expected future returns. This also means that RenVM does not require an oracle.

## Capital Efficiency

In any trustless interoperability protocol, it is always going to be necessary for the total value bonded to the network to exceed the total value locked by the network by some amount. Otherwise, the incentive to attack the network and steal the total value locked would exceed the total possible loss (the total value bonded). Depending on the protocol’s design, the required excess amount will differ. In RenVM, the excess amount is 3x; for every `1 BTC` worth of assets locked by RenVM, there should be `3 BTC` worth of REN bonded to RenVM by the Darknodes.

One core reason for existence of interoperability protocols is access to higher market capped assets. As such, it is important for interoperability protocols to implement their bond requirements intelligently so that the protocol is not unnecessarily capping the maximum supply of the cross-chain assets (i.e. the maximum safe total value locked).

In RenVM, the use of the REN token for the bond is what allows RenVM to be capital efficient. There is a positive feedback loop that exists in RenVM: as demand for cross-chain assets increases, the fees earned by RenVM increases, the value of REN increases, and the maximum supply of cross-chain assets increases. This is possible because the only utility for REN is to be bonded to RenVM, so the value of REN is derived solely from the fees earned. If RenVM was to use another asset, say ETH, then this positive feedback cycle would not exist and instead a liquidation mechanism would be required. See the chapter on the [REN](./REN) token for more information.

## Summary

RenVM incentivises Darknode participation by taking a small fee from all cross-chain transactions. By using REN as a bond, and only as a bond, the fees earned back the value of REN. As RenVM is used, and demand for cross-chain transactions increases, the value of REN increases too. This increases the maximum capacity that RenVM supports, ultimately allowing it to be capital efficient in ways that other protocols cannot. RenVM can also adjust these fees to ensure that the system is always well collateralised by its REN bonds, ensuring system safety.