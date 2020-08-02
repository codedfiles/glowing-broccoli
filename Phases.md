RenVM will move through multiple phases of deployment as it slowly becomes a fully decentralised network. This slow rollout allows the Ren core developers to ensure that the network is safe during its nascent days, a period where third-party developers/user might make mistakes, critical bugs might be found, or design flaws might be exposed. It is prudent to acknowledge that these things happen, especially with new and complex systems, and to take steps to mitigate their impact.

There are three phases to the rollout, **sub-zero**, **zero**, and **one**, where each phase is a milestone achieved with the complete deployment of feature-set. It is important to note that phases do not mark specific moments in time when a feature-sets will be enabled. It is not “all or nothing”. Rather, phases are moved to reflexively, in response to all the features in a feature-set having been enabled. Each feature can be enabled individually, one-by-one. Only after all of the features from a feature-set have been enabled will RenVM be said to have moved to the respective phase.

1. [Sub-zero](#sub-zero)
2. [Zero](#zero)
3. [One](#one)

## Sub-zero

Phase sub-zero is the opening phase of RenVM's existence, and was released on the 27th May 2020, at 11am GMT. It represents the minimum viable feature-set required to achieve interoperability between blockchains using MPC cryptography.

At the beginning of phase **sub-zero**, the Ren core developers will secure and maintain all nodes in the Greycore, and the Greycore will be the only group of nodes responsible for consensus and execution. Community nodes will be responsible for operating the P2P networking, including storage. This allows the Ren core developers to:

- respond quickly to downtime in the event of unexpected shutdowns,
- respond quickly to bugs that are found, by deploying fixes or triggering an emergency shutdown,
- help recover funds in the event that third-party developers make mistakes in their implementations, and
- help recover funds in the event that users make mistakes when interacting with RenVM.

During this phase, the codebase will be open-sourced, the Greycore will be expanded to include more node operators, and the governance of Greycore membership will be handed over to the community. Node operators, and REN holders, will have the ability to decide on the addition/removal of Greycore members. Once both of these features have been enabled, RenVM will move to phase **zero**.

By the end of phase **sub-zero**, RenVM will be semi-decentralised; the Greycore will be responsible for consensus and the execution of cross-chain transactions. Community nodes will be responsible for P2P networking and storage. Because other nodes are not operating consensus or execution, slashing cannot happen at any time during phase **sub-zero**. 

## Zero

Phase **zero** is the maturity phase for RenVM. It is the phase in which it will become fully decentralised, feature by feature.

1. The core will be enabled. The core is run by community nodes, and is responsible for consensus and the coordination RenVM. The randomness beacon is part of consensus, and will be maintained by input from both the core and the Greycore.
2. Shards will be enabled. Shards are constantly shuffled, and are responsible for the execution of cross-chain transactions. All execution requires two private keys, one from a shard, and one from the Greycore. This includes the locking of assets that are living away from their home blockchain.
3. Community governance will be enabled. This is mostly implicit in the running of community nodes that power the core and shards. However, some parameterisation of RenVM is possible, and community governance will become responsible for overseeing these changes. 

Once all of these features have been enabled, RenVM will be moved to phase **one**. 

By the end of this phase **zero**, RenVM will be fully decentralised. All networking, storage, consensus, execution, and governance will be fully distributed to REN holders.

When the core is enabled, node operators will be exposed to slashing risk in accordance with the slashing conditions for consensus. When shards are enabled, node operators will be exposed to slashing risk in accordance with the slashing conditions for execution. In general, slashing can occur whenever nodes behave maliciously, go offline for an extended amount of time.

## One

Phase **one** is the final phase of RenVM. This phase begins once all features have be released, and RenVM has become fully decentralised. From this point onwards, all changes to RenVM will be governed by node operators and REN holders.

This phase is named after the canonical “stable version”. In software development, “version one” is used to identify the first version of that can be considered stable for its intended purpose. Although RenVM has been stable since the beginning of phase **sub-zero**, the use of “one” here signifies stability in the context of full decentralisation.

Further development on RenVM will continue, but the decentralised nature of RenVM will mean that all changes must go through appropriate governance and consensus within the community before being deployed. As such, no specific feature-set can be anticipated for phase **one and beyond**.