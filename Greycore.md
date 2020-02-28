The Greycore is a special community governed shard that backs all gateway shards and the coordination shard. The Greycore has two core purposes:

1. guaranteeing the safety of assets under management by acting as a second signature on all minting and releasing (see [Gateways](./Gateways)), and
2. guaranteeing the uniform randomness of shard selection by generating secure random numbers (see [Sharding](./Sharding)).

In **RenVM SubZero**, members of the Greycore will be selected by the Ren team. By **RenVM One**, members will be selected through community governance. It is recommended that community members select members that have stake in the success of RenVM; projects/protocols that use RenVM for interoperability are incentivised by the success of their own ecosystems to resist bribery attempts, and investors backing these projects/protocols are also similarly incentivised. Community governance over membership ensures that the Greycore remains decentralised.

## Safety

The addition of a second signature requirement on all minting and releasing transactions improves safety. This is because an adversary must *still* attack gateway shards as if there was no Greycore, and then also attack the Greycore itself. Similarly, the coordination shard becomes more difficult to attack.

## Liveliness

The addition of a second signature requirement on all minting and releasing, if implemented naïvely, reduces liveliness. This is because an adversary can now choose to attack the Greycore *instead* of the normal gateway/coordination shards.

However, this can be mitigated by making sustained liveliness attacks on the Greycore harder than liveliness attacks in the gateway/coordination shards. This is achieved through the governance mechanism that selects members; if members of the Greycore become unresponsive, then they can be removed by the governance mechanism. This constant pruning of inactive Greycore members means that up to 2/3rd- of the Greycore can go offline simultaneously and liveliness can still be recovered.

## References

- [Gateways](./Gateways)
- [Sharding](./Sharding)