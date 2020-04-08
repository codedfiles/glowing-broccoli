Every Byzantine fault tolerant system needs to understand the conditions under which it can be attacked, and the limitations of its security. In this chapter, we discuss the safety and liveliness properties of RenVM, the conditions under which these properties can be broken, how RenVM prevents these conditions from being realised. At the end of the chapter, we look at the various practical complexities of executing an attack.

## Definitions

- *Darknodes* are the machines that power RenVM. Darknodes are required to bond 100K REN tokens, and must wait until the beginning of then next epoch before being admitted into a shard.
- An *epoch* is a discrete period of time at which new Darknodes become active, existing Darknodes become inactive, and fees are distributed.
- *Shards* are non-overlapping groups of Darknodes. At the beginning of every epoch, Darknodes are randomly shuffled into new shards.
- A shard is said to be *corrupted* when 1/3rd+ of the Darknodes in the shard are adversarial and coordinating.
- A shard is said to be *offline* when 1/3rd+ of the Darknodes in the shard are unable to send or receive messages to/from other Darknodes in the shard. This could be accidental, due to unexpected outages, or intentional, due to adversarial behaviour.
- An *origin* chain is the blockchain from which an asset originates. For example, Bitcoin is the origin chain for BTC.
- A *host* chain is a blockchain on which an asset, that does not originate from the host chain, is being represented. For example, Ethereum can be a host chain for BTC using renBTC for representation.

## Assumptions

An adversary is any participant, Darknode or otherwise, that does not adhere to the rules of the protocol. Adversaries can behave arbitrarily, and usually do so in an attempt to break one of the safety/liveliness properties of the system. In order to analyse the security of RenVM, we need to make some assumptions about the powers of an adversary.

1. Ethereum is a trusted computation engine. An adversary cannot cause a computation on Ethereum to produce an incorrect result, and there is known time after which the results of a computation cannot be changed or reverted.
2. Participants are economically rational. Participants will always attempt to maximise their profits and will become adversarial if it is profitable to do so.
3. The network is weakly asynchronous. All messages between honest participants are eventually delivered. However, no assumption is made with respect to the order of delivery, or with respect to messages between participants where at least one participant is adversarial.
4. Adversaries cannot adapt faster than the duration of an epoch. An uncorrupted shard cannot become corrupted within the duration of one epoch.
5. Adversaries are capital constrained. There is a limited amount of capital they can use to execute an attack, regardless of whether the attack is profitable.

## Safety

Safety properties are properties that must always — or never — be true. The safety properties of RenVM are guaranteed under the condition that no shard is ever corrupted. That is, no shard ever contains 1/3rd+ coordinating adversaries.

1. RenVM will never commit to more than one block at the same height.
2. RenVM will never execute a transaction from the block at height H+1 before executing all transactions from the block at height H.
3. RenVM will never produce a minting signature unless it has witnessed a respective lock on the origin chain. 
4. RenVM will never produce a releasing signature unless it has witnessed a respective burn event on a host chain.

### Safety Analysis

In this section, we will go through each of the safety properties and briefly discuss how RenVM guarantees them under the condition that less than 1/3rd of any shard is adversarial (also known as the <1/3rd adversarial condition).

First, we consider *Safety Property (1)*. In RenVM, consensus is responsible for committing to blocks of transactions that need to be executed. RenVM uses a modified version of the Tendermint consensus algorithm, called Hyperdrive. The Tendermint consensus algorithm is described in [“The latest gossip on BFT consensus” by Buchman et al](https://arxiv.org/abs/1807.04938), and formally describes a Byzantine fault tolerant consensus algorithm that is able to guarantee *Safety Property (1)* under the <1/3rd adversarial condition. The modifications made by Hyperdrive do not alter the consensus algorithm; they only formalise the process for fast-forwarding over missing blocks, and changing the signatories responsible for block production. These modifications, and their implementation, have been audited by ChainSecurity. See the [Hyperdrive Wiki](https://github.com/renproject/hyperdrive/wiki) for more information.

Next, we consider *Safety Property (2)*. The Tendermint consensus algorithm requires the existence of an `isValid` function that determines the validity of a block. It guarantees that, under the <2/3rds adversarial condition, no block that is invalid can be committed. For a block at height H+1 to be valid, RenVM requires it to embed the state after the execution of all transactions in the block at height H. It follows that, unless >=2/3rds of Darknodes are adversarial, no block can be committed at height H+1 until after the execution of all transactions in the block at height H. It is important to note that the `isValid` function is locally computable, so adversaries cannot influence the decision of an honest Darknode. It is also important to note that the output state resulting from the execution of a transaction is unique with respect to the transaction and the input state (no two blocks will have the same state after execution).

Next, we consider *Safety Property (3) and (4)*. In RenVM, the execution of a cross-transaction involves producing a minting or releasing signature. Cross-chain transactions that mint an asset on a host chain require minting signatures, and those that release assets back to their origin chain require releasing signatures. To produce this minting or releasing signature, a shard uses the RZL MPC algorithm to sign a digest. The shard uses an ECDSA private key that was generated using the RZL MPC algorithm at the beginning of the epoch, and is not known to anyone. The [Shamir’s secret sharing](https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing) threshold used by RZL MPC algorithm is 1/3rd. This means that a signature cannot be produced, and the underlying ECDSA private key cannot be revealed (allowing an adversary to produce a signature independently), unless >=1/3rd Darknodes are adversarial and coordinating. The RZL MPC algorithm is currently under audit by the Consensys Diligence team.

### Safety Incentives

Safety properties are guaranteed under the <1/3rd adversarial conditions. However, because of *Assumption (2)*, it is important to know why the <1/3rd adversarial condition holds. This section will briefly discuss the incentives for Darknodes to be non-adversarial. Deeper analysis is deferred to later sections that go into the prevention of different attack scenarios.

- Darknodes are required to bond themselves to RenVM with a bond of 100,000 [REN](./REN). This bond is registered with an Ethereum smart contract, called the [Darknode Registry](./Darknode-Registry). After registration, the Darknode must wait until the beginning of the next epoch before being admitted into any shards. After deregistration, the Darknode must wait until the beginning of the next epoch, and then another full epoch, before being able to withdraw their bond. Darknode bonds that have not been withdrawn can be slashed.
- Darknodes that propose, prevote, or precommit two different blocks in the same height and round can have their bonds slashed by submitting the different proposes, prevotes, or precommits to an Ethereum smart contract, called the [Darknode Slasher](./Darknode-Slasher).
- Shards that produce minting signatures without witnessing a respective lock transaction on the origin chain can have their bonds slashed. At any time, a challenger can submit a challenge — with a bond — to the Darknode Slasher. A prover must produce an [SPV proof](https://en.bitcoinwiki.org/wiki/Simplified_Payment_Verification) of existence for the respective lock transaction before the end of the next epoch, or every Darknode in the challenged shard will have their bond slashed. If this SPV proof is successfully produced, then the challenger loses their bond to the prover.
- Shards that produce releasing signatures without witnessing a respective burn event on the host chain can have their bonds slashed. At any time, a challenger can submit a challenge — with a bond — to the Darknode Slasher. This challenge contains an [SPV proof](https://en.bitcoinwiki.org/wiki/Simplified_Payment_Verification) of existence for the release transaction. A prover must produce an [SPV proof](https://en.bitcoinwiki.org/wiki/Simplified_Payment_Verification) of existence for the respective burn event before the end of the next epoch, or every Darknode in the challenged shard will have their bond slashed. If this SPV proof is successfully produced, then the challenger loses their bond to the prover.

The registration and deregistration of bonds is handled by an Ethereum smart contract, as are the submission of challenges (and proofs). Under *Assumption (1)*, an adversary cannot escape the slashing conditions, assuming someone notices their malicious behaviour. Any participant in RenVM, Darknode or otherwise, is likely to notice such malicious behaviour.

## Liveliness

Liveliness properties are properties that must eventually be true. The liveliness properties of RenVM are guaranteed under the condition that no shard is ever offline. That is, no shard ever contains >=1/3rd Darknodes that are unable to communicate with the rest of the shard. This is counted cumulatively across Darknodes that are accidentally unable to communicate, and Darknodes that are intentionally refusing to communicate.

1. RenVM will eventually commit to a block at every height.
2. RenVM will eventually execute every transaction in a committed block.

### Liveliness Analysis

In this section, we will go through each of the liveliness properties and briefly discuss how RenVM guarantees them under the condition that less than 1/3rd of the Darknodes in any shard are offline (also known as the <1/3rd offline condition).

First, we consider *Liveliness Property (1)*. As with *Safety Property (1)*, this property follows from the use of the Tendermint consensus algorithm. The Tendermint consensus algorithm guarantees this liveliness property under *Assumption (3)* (required by the Tendermint consensus algorithm) and the 1/3rd- offline condition.

Next, we consider *Liveliness Property (2)*. Again, as with *Safety Property (3) and (4)*, this follows from the use of the RZL MPC algorithm and *Assumption (3)* (also required by the RZL MPC algorithm). The Shamir’s secret sharing threshold in RZL MPC is 1/3rd. This means that the underlying ECDSA private key can always be recovered as long as 1/3rd+ Darknodes are not offline. Furthermore, it means that only 2/3rd+ of the Darknodes are required to complete signing and key generation. This implies signing and key generation will make progress under the 1/3rd- offline condition.

### Liveliness Incentives

Both liveliness properties require Darknodes to contribute non-zero cost resources to powering RenVM (CPU time, storage space, and network bandwidth). Under *Assumption (2)* this requires an economic reward that exceeds the non-zero costs. To this end, RenVM charges users a small fee whenever they a cross-chain transaction is executed. Before execution can happen, consensus must happen, and so the fee incentivises both processes as long as it covers the cost of both processes. See the chapter about [fees and economics](./Fees-and-Economics) for more information.

## Rational Attacks

In this section, we look at Sybil and bribery attacks; the two simplest and most profitable attacks. We will discuss how RenVM prevents these attacks from happening in the face of rational adversaries (adversaries seeking to make a profit). In the next section, we extend this discussion by looking at how RenVM protects itself against irrational adversaries (adversaries that do not care about profit).

### Sybil

A Sybil attack is where an adversary registers a large number of Darknodes in an attempt to corrupt one or more shards. Any adversary that succeeds in a Sybil attack will win the same reward as in a bribery attack — stealing the assets locked by the corrupted shard — but at greater cost than a bribery attack. There is a reasonably simple intuition behind this result. First, consider a few points:

- A shard corrupted by a Sybil attacker requires >=1/3rd of the Darknodes in that shard to be owned by the Sybil attacker.
- A corrupted shard that steals any of its origin assets will cause the slashing of all bonds of all Darknodes in that shard.  
- A Sybil attacker that owns >1/3rd of the Darknodes in a shard will lose more bond value than a briber that bribes exactly 1/3rd of the Darknodes.

Now, consider that the membership of shards is random. Unless a Sybil attacker is extremely lucky, it is highly improbable that in any shard they manage to corrupt they will own exactly 1/3rd of the Darknodes. Even if a Sybil attacker was lucky, they would still incur a loss equal to that incurred by a briber. It follows that Sybil attackers, with high probability, incur a higher cost than bribers for the same winnings.

### Bribery

A bribery attack is where an adversary corrupts a shard by coordinating with 1/3rd+ of its Darknodes and bribing them to execute an attack. In the case of a successful bribe, the attacker is able to steal all of the origin assets locked by the shard. However, doing so would result in a release of the origin assets without a respective burn event from the host chain, and this results in the bonds of all Darknodes in the shard being slashed.

It follows that, under *Assumption (2)*, the attacker would have to bribe Darknodes with more value than their REN bonds are worth. Because such a bribe needs to be paid to at least 1/3rd of the Darknodes in the shard, a bribery attack is not profitable as long as the sum value of all REN bonds of all Darknodes in the shard is greater than 3x the value of origin assets locked in the shard.

This constraint is enforced economically by adjusting the [minting, burning, and continuous fees](./Fees-and-economics). REN has the sole utility of being used as a bond for the Darknodes. As such, its value is derived solely from the fees earned by the Darknodes. Since Darknodes are responsible for the governance of RenVM, they are able to adjust the minting and burning fees to ensure that the value of REN is sufficiently high to protect against bribery attacks. They can also adjust the continuous fee to reduce the amount of locked assets under management. It is worth noting, no explicit price oracle is needed, since the Darknodes individually vote to adjust fees based on their own valuations of their REN bond.

## Irrational Attacks

Up to this point, we have only considered rational adversaries that are trying to profit from an attack. Although irrational adversaries can be difficult to defend against, RenVM does offer some protections against them.

### Epochs

An irrational attacker that is attempting to bribe a shard needs to coordinate with >=1/3rd of the Darknodes in that shard before the next epoch begins. Otherwise, the beginning of the next epoch will shuffle all of the Darknodes in that shard, and the attack will need to start again. The attacker must find a way to contact Darknode operators (who are not required to make any contract information public), and proposition them without alerting the wider community to their intentions (who would then be incentivised to release their locked assets to keep their funds safe, assuming the attacker was sufficiently noteworthy). Furthermore, the attacker would need to convince the Darknode operators that it is better to be bribed than to vote to increase the RenVM fees and generate more revenue that way. Under *Assumption (4)*, this is assumed to not be possible in the timeframe of an epoch (24 hours).

This argument also applies to "hacking", where an attacker may try to forcefully gain control over a Darknode without needing to bribe them. This could be the result of an insecure password, or a poor security configuration. While the shuffling of shards every epoch makes this hard, the Ren team has also built the [Darknode CLI](https://github.com/renproject/darknode-cli). It is a command-line tool that configures Darknodes with safe default settings. An attacker would need to successfully hack >=1/3rd of Darknodes in the same shard within 24 hours, otherwise all progress made up to that point is wasted with high probability (assuming that Darknode operators semi-regularly update their software to make sure its running the latest official version).

### Capital Requirements

Even when an irrational adversary does not care about making profit, they are still required to either launch a Sybil or bribery attack to steal assets from RenVM. Such an attack requires a minimum capital spend: 1/3rd the sum value of REN bonds in a shard. RenVM protects against these attacks by controlling (a) the fees earned by Darknodes, (b) the number of Darknodes in a shard, and (c) the minimum REN bond per Darknode. Under *Assumption (5)*, there exists such a set of parameters that the minimum capital requirement for an irrational attack is too high. For example, at a market price of 0.05 USD per REN, a shard size of 256, and a minimum REN bond of 100000 REN, an irrational attacker would have to have access to 425000 USD before being able to attempt an unprofitable attack. It will ultimately be up to the Darknodes to reach an agreement on parameters that are acceptable by them and their users.

## Summary

RenVM makes use of a modified version of the Tendermint consensus algorithm to guarantee the consensus mechanism cannot be be made unsafe (or halted), unless 1/3rd or more of the Darknodes are adversarial and coordinating (or offline). The same guarantees are made for execution by making use of the novel RZL MPC algorithm.

To incentivise Darknodes to be non-adversarial, RenVM has a series of slashing conditions that will slash the bonds of malicious Darknodes. These slashing conditions, coupled with economic policies to adjust fees earnt, ensure that it is not profitable to attempt an attack against RenVM. Furthermore, an irrational attacker that is happy to make a loss would still need to have access to a large amount of initial capital as well as a way to collude with large numbers of unknown Darknodes in a short period of time.