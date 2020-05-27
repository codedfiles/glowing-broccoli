# Fees and Economics
RenVM assumes that Darknodes are rational, and will attempt to maximise their own profit. Because powering RenVM has a non-zero cost associated with it — CPU cycles, disk space, network bandwidth, and a REN bond are not free — Darknodes need to be economically rewarded. To this end, every time RenVM executes a cross-chain transaction, it takes a small fee and pays it to the Darknodes as a reward for powering the network. It is worth noting: some cross-chain transactions also require RenVM to pay for fees on the underlying chain (for example, the SATs-per-byte fee charged on Bitcoin). This fee is applied on top of the usual fees charged by RenVM.

0. [Too Long; Didn't Read](#tldr)
1. [Minting and Burning Fee](#minting-and-burning-fee)
2. [Continuous Fee](#continuous-fee)
3. [Underlying Fee](#underlying-fee)
4. [Example](#example)
    1. [Minting](#minting)
    2. [Holding](#holding)
    3. [Burning](#burning)
5. [Economic Security](#economic-security)
    1. [Goals](#goals)
    2. [Bonding](#bonding)
    3. [Constraints](#constraints)
    4. [Adjustment](#adjustment)
6. [Fee Curves](#fee-curves)
    1. [Minting Fee Curve](#minting-fee-curve)
    2. [Burning Fee Curve](#burning-fee-curve)
    3. [Continuous Fee Curve](#continuous-fee-curve)

## TL;DR

RenVM charges fees for all cross-chain transactions.

- Minting fees are charged when minting pegged assets on a host chain (e.g. sending BTC from Bitcoin to Ethereum).
- Burning fees are charged when burning pegged assets from a host chain (e.g. sending BTC from Ethereum to Bitcoin).
- Continuous fees are charged per-second for holding pegged assets.
- Underlying fees are charged based on congestion of the underlying network.

| | Fee |
|---|---|
| Minting | 0.1% |
| Burning | 0.1% |
| Continuous | 0.0% |
| Underlying | ~5K-50K SATs |

| | Receive |
|---|---|
| Lock-and-mint | `(sent - underlyingFee)*(100% - mintingFee)` |
| Burn-and-release | `burned*(100% - burningFee) - underlyingFee` |
| Burn-and-mint | `burned*(100% - burningFee)*(100% - mintingFee)` |

## Minting and Burning Fee

| | Fee | Lock-and-mint | Burn-and-release | Burn-and-mint |
|---|---|---|---|---|
| Minting | 0.1% | Y | N | Y |
| Burning | 0.1% | N | Y | Y |

The *minting fee* is applied to lock-and-mint and burn-and-mint transactions. It is applied after any underlying blockchain fees have been applied. The *burning fee* is incurred by burn-and-release and burn-and-mint transactions. It is applied before any underlying blockchain fees have been applied.

These fees reward Darknodes for running the consensus and execution algorithms, which requires a non-trivial amount of resources. But, these fees also serve another purpose: keeping the value of bonded REN above the value of locked assets. Transferred volume is typically orders of magnitude higher than locked volume, so the majority of the value of bonded REN value comes from minting and burning fees.

## Continuous Fee

The *continuous fee* is incurred by all holders of pegged assets (assets living on a host chain, with a one-to-one peg to assets that are locked in RenVM, waiting to be redeemed). This fee is charged per-second, but is usually set to zero. Continuous fees do not contribute significantly to the rewards earned by Darknodes, and exist primarily as a parameter that can be algorithmically adjusted in order to maximise the [economic security](#economic-security) of RenVM when the adjustment of minting and burning fees is not sufficient. 

The continuous fee is implemented through a decreasing exchange rate between the pegged asset and the respective origin asset. This is best explained through an example, so we will look at renBTC/BTC, but the same rules apply to other pegged/locked asset pairs.

Although renBTC is always pegged one-to-one with BTC *with respect to value*, it is not pegged one-to-one in absolute balance amounts. The ratio of absolute balances is known as the *exchange rate*, and it slowly decreases over-time (this design was inspired by cTokens by Compound, but is used to pay fees instead of earn interest).

- When you mint, you will receive `minted = locked*exchangeRate`.
- When you burn, you will receive `released =  burned*exchangeRate`.

The exchange rate drops second-by-second, in accordance with the current continuous fee (which is usually zero). This means that by continuously holding renBTC, the amount of BTC that you can get back slowly decreases. However, regardless of the current exchange rate, if you lock 1 BTC you will receive 1 BTC worth of renBTC, and if you burn 1 BTC worth of renBTC you will receive 1 BTC.

For example, Alice locks 1 BTC and mints 1 renBTC (current exchange rate is 1:1). If the continuous fee is 5% p/a, then the exchange rate will be dropping by 5% per year. After 1 year, the exchange rate is 100:95 and Alice can burn her 1 renBTC to receive 0.95 BTC. Now, Bob wants to lock 1 BTC. The  exchange rate is 100:95, so he will receive 1.05263157 renBTC. Bob immediately sends this to Charlie, who burns the 1.05263157 renBTC and because the exchange rate is still 100:95 he receives 1 BTC from RenVM. As you can see, this technique of slowly lowering the exchange rate means that Alice, who held renBTC for 1 year, incurred the appropriate continuous fee. However, Bob and Charlie, who did not hold renBTC for any significant period, incurred no fees.

The renBTC token (and all other pegged ren tokens) will return the raw balances when calling `balanceOf`. That is, if Bob called `renBTC.balanceOf` he would have seen 1.05263157 renBTC. This balance does not change over time, regardless of the continuous fee. However, `balanceOfUnderlying` will return the rate-adjust balance. That is, if Bob called `renBTC.balanceOfUnderlying` he would have seen 1 BTC. This balance does change over time. RenVM encourages a user experience where users never directly hold or interact with renBTC, so these semantics will not be relevant to them.

## Underlying Fee

For lock-and-mint and burn-and-release transactions, RenVM needs to submit transactions on the underlying chains. For example, when transferring BTC from Bitcoin to Ethereum, RenVM needs to submit a Bitcoin transaction, and when transferring BTC from Ethereum to Bitcoin, RenVM again needs to submit a Bitcoin transaction. Submitting these underlying transactions often incurs a fee (most blockchains have their own fees). This is known as the *underlying fee* and it is applied in addition to the minting and burning fees. This fee gives no profit to RenVM, is solely for getting the submitted transaction mined, and is flat (not percentage based).

- For lock-and-mint transactions, the underlying fee is charged before the minting fee. This means that the received amount will be `received = (sent - underlyingFee)*(100% - mintingFee)`.
- For burn-and-release transactions, the underlying fee is charged after the burning fee. This means that the received amount will be `received = burned*(100% - burningFee) - underlyingFee`.
- For burn-and-mint transactions, there is no underlying fee. This is part of the reason why burn-and-mint transactions were introduced: to avoid the underlying fee.

## Example

It is helpful to look at an example to get an understanding of how all of these fees come together. In this example, we will consider BTC being sent to Ethereum and then back to Bitcoin. This will require two transactions: a lock-and-mint transaction (to get BTC to Ethereum) and a burn-and-release transaction (to get BTC off Ethereum and back to Bitcoin).

### Minting

Let’s say that Alice has some BTC and she wants to send this BTC to Ethereum. She generates a Bitcoin gateway address, and sends 0.8 BTC to this gateway address. We assume that 0.8 BTC is the amount that is received by the gateway address, after she has paid her Bitcoin transaction fees.

First, RenVM must transfer the 0.8 BTC from the gateway address to its custody. This step incurs an underlying fee of 5K SATs. This is not paid to RenVM, it is paid to the Bitcoin miners so that the Bitcoin transaction doing this transfer will be mined within a reasonable time. This fee is flat and does not scale with the amount of BTC that Alice is transferring, but it can change in response to congestion on Bitcoin. After accounting for this fee, RenVM receives `0.8 BTC - 0.00005 BTC = 0.79995 BTC`.

Now, RenVM must produce a minting signature by invoking the RZL MPC algorithm on one of its execution shards. This step incurs a fee of 0.1% on the amount received by RenVM. In this case, RenVM will receive `0.79995 BTC * 0.1% = 0.00079995 BTC` and Alice will receive `0.79995 - 0.00079995 BTC = 0.79915005 renBTC` on Ethereum. Alice has transferred $7,040 worth of BTC from Bitcoin to Ethereum, and she has been charged a total of $7.47956 in fees (including all of the Bitcoin transaction fees, and assuming 1 BTC = $8,800).

### Holding

Alice likes to have renBTC on Ethereum. After all, renBTC is faster to transfer and can be used in more exciting applications without trust or centralised third-parties. As such, Alice holds on to her renBTC. One day, RenVM adjusts its continuous fee from 0% p/a to 5% p/a, in an attempt to discourage people from holding renBTC (unless they are generating a better yield than 5% p/a). This can happen when too many people are holding renBTC, which requires effort from the Darknodes to keep secure, and too few people are performing cross-chain transactions.
Alice decides she would rather not incur this fee, and instead wants to redeem all of her 0.79915005 renBTC for BTC. There is a delay between the changing of the continuous fee and the charges beginning to apply, so we will assume that Alice responds fast enough to avoid incurring any of the continuous fee.

### Burning

To redeem her BTC, Alice initiates are burn-and-release transaction by burning all of her renBTC on Ethereum and associating it with her Bitcoin address. RenVM witnesses the burn, and then prepares, signs, and submits a Bitcoin transaction that releasing BTC to her nominated Bitcoin address.

First, RenVM must prepare and sign the Bitcoin transaction by invoking the RZL MPC algorithm. This step incurs a fee of 0.1% on the amount burned by Alice. In this case, RenVM will receive `0.79915005 renBTC * 0.1% = 0.00079915 BTC` and there will be `0.7983509 BTC` left to be released to Alice.

Now, RenVM must submit the Bitcoin transaction so that Alice can receive her BTC. Similar to the minting example, this step incurs an underlying fee of 5K SATs fee that is paid to the Bitcoin miners, so that the Bitcoin transaction can be mined. This means that Alice will receive `0.7983509 BTC - 0.00005 BTC = 0.7983009 BTC`. Alice has redeemed $7,032.52044 worth of BTC from Bitcoin to Ethereum, and she has been charged a total of $7.47252 in fees (including all of the Bitcoin transaction fees, and assuming 1 BTC = $8,800).

## Economic Security

Any interoperability protocol that uses the tokenised representation model has a certain amount of value locked in its custody at any point. We call this the *locked value*. In decentralised interoperability protocols, we need to make sure that this locked value is secure against rational and irrational adversaries (where rational adversaries want profit, and irrational adversaries want to watch the world burn, regardless of profitability).

Here, we define *economic security* as the ability to protect oneself against rational and irrational adversaries using economic parameters. Included in this definition is the ability to recover from an attack, should one ever be successful. It is worth point out that RenVM has several other non-economic mechanisms to protect itself against rational and irrational adversaries, but this section focuses solely on the economic ones.

### Goals

There are some specific goals that we would like to achieve with our economic security model:

1. RenVM only slashes Darknodes in malicious shards,
2. RenVM can always restore the one-to-one peg even after a successful attack, and
3. RenVM can scale to meet demand.

These ideal requirements rule out liquidation mechanisms, which slash non-malicious parties when their collateral requirements are not met, cannot restore the one-to-one peg after times of high market volatility, and cannot automatically scale the value of collateral to meet demand. Here, we present an alternate solution.

### Bonding

At the heart of RenVM’s economic security model is the REN bond. This is a 100K REN bond that must be submitted by every Darknode. It is a commitment to good behaviour,  timely responses, and honest participation in governance. Without submitting a 100K REN bond, a machine is just a machine, and is not considered a Darknode by other participants in RenVM.

This bond is the most basic building block for economic security. Its existence means that any attacker, rational or irrational, must have access to some minimum amount of capital before they can even think about attempting an attack. The *bonded value* refers to the total value of REN currently bonded by Darknodes. The goal of RenVM’s economic security model is to keep this bonded value above the locked value (preferably above 3x the locked value).

### Constraints

1. The `3L < B` constraint refers to  the goal of keeping the bonded value (`B`) in any one shard at least 3x higher than the locked value (`L`) of that shard. Since the most efficient attack against RenVM requires accepting the loss of `B/3+` (compromising 1/3rd+ of the Darknodes in the shard and therefore losing their bonds), the `3L < B` constraint implies that it is not profitable to attack RenVM. This is true for both bribery and Sybil attacks, regardless of how easy these attacks are to execute successfully. In practice, bribery and Sybil attacks are both made very difficult by the other security mechanisms of RenVM.
2. The `L < B` constraint refers to the goal of keeping the locked value (`L`) in any one shard lower than the bonded value (`B`) of that same shard. While this constraint holds, RenVM can recover from a successful attack. This is done by slashing the bonded value of the malicious shard and using it in an auction to buy-back-and-burn `L` amount of pegged assets. This restores the one-to-one peg and holders of pegged assets incur no loss. In practice, Darknodes would be expected to buy-back their own bonds from this auction, because it minimises their losses, and it is safe to assume that even an irrational adversary would seek to minimise losses.

### Adjustment

To keep the `L < B` and `3L < B` constraints true, RenVM has two options: increase `B` or decrease `L`. Increasing `B` can be thought of as increasing the capacity, or economic bandwidth, of RenVM. It respects the constraints by increasing the bonded value, allowing more locked value. Conversely, decreasing `L` can be thought of as forcefully lowering demand. As such, RenVM is designed with a strong preference for increasing `B`.

While `3L < 2B`, RenVM will make adjustments to its minting and burning fees in an attempt to restore/maintain the `3L < B` constraint, where RenVM is its most secure. The continuous fee should be zero during this period. See the [minting fee curve](#minting-fee-curve) and the [burning fee curve](#burning-fee-curve).

When `3L > 2B`, RenVM will stop adjusting its minting and burning fees, and start adjusting the continuous fee. The continuous fee will be raised above zero, and continue to be raised, until `3L > 2B` is restored. See the [continuous fee curve](#continuous-fee-curve).

To adjust fees, Darknodes must first have a way to compute `B`. The most obvious option is to use a price feed, and compute `B` based on the market price of REN. However, REN is likely to have low liquidity on spot markets due to its use in bonding, and the spot market may not reflect a fair valuation of REN, because it can be temporarily manipulated by an adversary. Furthermore, the bonded value of REN is only important because it represents the expected loss incurred by Darknodes that are responsible for the loss of locked assets. This loss is not based on the market value, but on the value perceived by the Darknodes themselves.

Because REN is used solely for bonding, we another option. We can use a discounted cash flow model instead of an explicit price feed. This is (a) independent of liquidity, (b) harder to manipulate, and (c) a more accurate representation of the value of a REN bond to a Darknode. Recall that a Darknode is able to earn rewards because of its REN bond. As a naïve example, Darknodes that are happy with 10% ROI per year should value their REN bond at 10x their expected yearly earnings, regardless of the current market price (and the market price would be expected to eventually mean revert around this value, albeit with a high deviation).

Darknodes are responsible for the algorithmic adjustment of fees, based on computing `B` using the discounted cash flow model. Darknode operators can configure their Darknodes to use (a) different risk parameters for the model, (b) different windows for computing their average earnings, and (c) different price feeds for normalising the value the fees and locked assets. From this, Darknodes can assess the `L < B`, `3L < 2B`, and `3L < B` constraints and move to adjust fees accordingly.

Users are also able to independently assess these constraints, and arrive at their own determination about the economic security of RenVM. This incentivises Darknodes to be honest, since unreasonable valuations would cause users to stop using RenVM out of concern for its security, and this would in turn diminish all earnings. Put another way, there is no point for Darknodes to give a false assessment of L vs B, because users do not act based on Darknode assessments, but their own.

## Fee Curves

[minting_plot]: ./fee_plots/output/minting.png
[burning_plot]: ./fee_plots/output/burning.png
[continuous_plot]: ./fee_plots/output/continuous.png

These fee curves are an initial attempt at defining the minting, burning, and continuous fees with respect to the `L/B` where `L` is the locked value and `B` is the bonded value. These curves are subject to change based on the results observed during Phase SubZero. During Phase Zero (and beyond), RenVM governance will have the ability to modify these curves.

### Minting Fee Curve

![Minting Fee Curve][minting_plot]

### Burning Fee Curve

![Burning Fee Curve][burning_plot]

### Continuous Fee Curve

![Continuous Fee Curve][continuous_plot]
