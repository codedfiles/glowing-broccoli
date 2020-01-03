Safety is defined as a property that **always** holds, and liveliness is defined as a property that **eventually** holds. In this section, we discuss these properties and the conditions under which they hold in RenVM. We are specifically interesting in how these properties relate to the interoperability gateways, since these are currently the only contracts supported by RenVM.

## Safety

​Both the [Tendermint consensus algorithm](https://arxiv.org/abs/1807.04938) and the [RZL sMPC algorithm]() have a safety threshold of 1/3rd+. This means that one adversary must successfully attack 1/3rd (or more) of the Darknodes in a [shard]() before it is possible to break the safety properties of that shard.

Shards must never:

- commit to two different blocks at the same height,
- mint a tokenised asset without first locking the origin asset in equal quantity, or 
- release an origin asset without first burning the tokenised asset in equal quantity.

### Assumptions

When analysing the safety of RenVM, we make the following assumptions:

1. Ethereum is a trusted computational engine that is both safe and lively,
2. all messages in the network must eventually be delivered (the network is partially synchronous),
3. Darknodes cannot be physically compromised,
4. Darknodes cannot run malicious software without the consent of its owner,
5. Darknode owners are economically rational and will not voluntarily incur a loss, and
6. a successful safety attack on RenVM will result in REN eventually dropping the majority of its value.

### Analysis

An attacker must attack at least 1/3rd of the Darknodes in that shard to break safety properties (see [Consensus]() and [Execution]()). To achieve this, the attacker must either:

- bribe 1/3rd of the Darknode owners, called the **bribery attack**, or
- acquire enough REN that the attacker can be randomly shuffled into owning 1/3rd of the shard, called the **bonding attack**.

Either way, the attacker must spend 1/3rd+ of the value of REN bonded in a shard.

We define `R` to be the total value of REN bonded in a shard. In the **bribery attack**, an attacker must bribe 1/3rd+ of Darknode owners by offering them a reward. It follows from assumption (5) and (6) that the attacker must spend more than `R/3` on rewards. Therefore, we can prevent such an attack by restricting the total value of locked assets, `L`, to be less than `R/3`.

​In the **bonding attack**, an attacker must register enough Darknodes that they can be randomly selected to own 1/3rds+ of the Darknodes in the shard. It turns out that this is more expensive than a bribery attack, and so making the bribery attack unprofitable is sufficient to make the bonding attack unprofitable.  Intuitively, this is because the bonding attack requires more than `R/3` worth of bond from the attacker; they must corrupt a portion of a network that is much larger than one shard (see [Bribery vs Bonding](https://github.com/renproject/ren/wiki/Safety-and-Liveliness#Bribery-vs-Bonding)).

## Fees

Previously, we stated that we must restrict `L <= R/3`. This could be done using some kind of liquidation mechanism, however, this ultimately degrades the tokenised assets into a synthetic. When liquidation is involved, you cannot always get origin assets back in exchange for your tokenised assets. Instead, you get back an unrelated asset that is equal in value, assuming that the market is sufficiently liquid.

Instead of liquidiation, RenVM does this by allowing governance over dynamic minting/burning/continuous fees. As `L` approaches `R/3`, the minting fee approaches `+inf`. On the other hand, the burning fee approaches `+0`. Because there is a continuous fee compounding by the second, users become incentivised to burn tokenised assets, lowering the value of `L`. By tuning minting/burning fees, RenVM can enforce that `L` does not exceed `R/3` from below.

RenVM must also enforce that `R/3` does not drop below `L` from above. This can be done by tuning the continuous fee. The value of `R` is dependent on `L` and the continuous fee (it is also dependent on the minting/burning fees, but this can only cause the value of `R` to increase). If `R` is too low, and there is a risk of `R/3 < L`, then RenVM governance can increase the continuous fee until (a) people burn tokenised assets to avoid the fee (reducing `L`), (b) the value of `R` increases, or both.

### Bribing and Bonding Attacks

> Work in progress.

## Liveliness

As with safety, the liveliness threshold of the Tendermint consensus algorithm and the RZL sMPC algorithm are 1/3rd+. Furthermore, the liveliness properties of the Tendermint consensus algorithm and the RZL sMPC algorithm both hold in weakly synchronous networks.

Shards must:

1. eventually commit a block at every height,
2. eventually mint tokenised assets when origin assets are locked, and
3. eventually release origin assets when tokenised assets are burned.

Darknodes that fail to participate in consensus or execution are contributing to a potential liveliness failure (the breaking of one of the liveliness properties). Therefore, economic incentives are put in place to encourage Darknodes to participate, and those that fail to participate are removed from the network.

### Analysis

> Work in progress.

