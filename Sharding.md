The Darknodes that power RenVM are partitioned into randomly sampled, continuously shuffling shards. These shards are smaller than the entire network, so they are able to operate more safely and efficiently. They are independent of one another, so they can run in parallel and any failures are isolated.

## Gateway Shards

*Gateway shards* are responsible for generating, using, and rotating secure ECDSA private keys. These secure ECDSA private keys are generated in secret using the [z0](https://github.com/renproject/z0) sMPC engine, and cannot be revealed or used maliciously unless an adversary is able to corrupt 1/3rd+ of the shard. These secure ECDSA private keys are used to interoperate assets from one blockchain to another, using [gateways](./Gateways).

Because gateway shards are independent from one another, any successful attack on a gateway shard is isolated to that shard, and will only remove funds from that shard. This prevents failures in individual shards from propagating throughout the network and causing mass loss of funds.

The secure ECDSA private keys used by gateways shards must be rotated at the beginning of every epoch. This is required so that, as Darknodes exit the network, they do not continue to know shares of actively used ECDSA private keys. After exiting the network, Darknodes no longer have a bond that incentivises them against revealing their shares. During rotation, the gateway shards in epoch `E` generate new secure ECDSA private keys for the gateway shards in epoch `E+1`. This generation results in shares that are encrypted specifically for the Darknodes in `E+1`, and no Darknode in `E` knows any of the shares generated. After generation, the gateway shards in `E` sign transactions that forwards all assets to the newly generated secure ECDSA private keys.

Assets and transactions are load-balanced between Gateway shards, ensuring that all shards have the the same amount of assets under management at all times. This equal distribution of assets maximises the capacity of RenVM, and ensures that isolated failures can only impact `1/N` amount of assets, where `N` is the number of gateway shards.

Currently, the number of Darknodes assigned to a gateway shard is 100. 

## Coordination Shard

The *coordination shard* is responsible for the coordination of gateway shards. It is responsible for selecting which Darknodes belong to which shards (including the coordination shard itself), and it is responsible or reaching consensus on which transactions will be processed by which shards. It does not execute these transactions, and it does not have a secure ECDSA private key for holding funds.

Blocks in the coordination orders transactions, assign those transactions to specific gateway shards, and generate secure random numbers. These secure random numbers are generated using the [z0](https://github.com/renproject/z0) sMPC engine, and are guaranteed to be uniformly random unless an adversary can corrupt 2/3rd+ of the coordination shard.

Currently, the number of Darknodes assigned to the coordination shard is 100.

## Greycore Shard

The *Greycore* is a shard made up of Darknodes that are selected through community governance, instead of randomisation. Its members should be those that have developed reputations with the community, and have a stake in the safety/liveliness of RenVM.

The Greycore acts as a secondary signature for all gateway shards; gateway shards cannot mint or release assets without this second signature. The Greycore also acts as a secondary random number generator for coordination shards. See [./Greycore](./Greycore) for more information about how the Greycore works, how its members are selected, and why it improves safety without compromising liveliness.

The number of Darknodes in the Greycore depends only on community governance.

## Epochs

An *epoch* is the discrete time interval at which shards will rebase. During rebasing

- new Darknodes that are pending registration will be activated, and can begin participating (see [Darknode Registry](./Darknode-Registry)),

- old Darknodes that are pending deregistration will be deactivated, and can no longer participate (see [Darknode Registry](./Darknode-Registry)),

- existing Darknodes are shuffled to form new shards, and

- all gateway private keys are generated.

Rebasing every epoch helps to mitigate against attacks from adaptive adversaries that seek to gradually corrupt Darknodes in a shard, whether by bribing them or hacking them. Rebasing also allows new Darknodes to enter the protocol, and existing Darknodes to exit the protocol, without disrupting liveliness.

### Selection

Selection is the process by which Darknodes are placed into gateway shards and the coordination shard. It is important that selection is random and unbiased, otherwise cabals could seek to corrupt selection in an attempt to end up in the same shard together.

When it is time to rebase an epoch, the coordination shard will produce a *rebase block* (see the [Hyperdrive Wiki](https://github.com/renproject/hyperdrive/wiki)). A rebase block is a special that has no transactions and exists solely to drive the rebasing of shards. To execute a rebase block, the coordination shard and Greycore shard reveal their secure random numbers and use it as a seed to shuffle Darknodes into the gateway shards and the coordination shard.

The selection algorithm must:

- define exactly one coordination shard,
- define as many gateway shards as possible,
- always assign as many Darknodes to as many shards as possible, and
- never assign a Darknode to more than one shard.

### DKG

The constant (de)registration of Darknodes will often result in a different number of shards between epoch `E` and epoch `E+1`. When proposing a rebase block, the coordination shard must propose transactions from all gateway shards in `E` to all gateway shards in `E+1`. It must keep the assets under management equally distributed between all gateway shards in `E+1`.

To receive forwarded assets, every gateway shard in `E+1` needs a newly generated secure ECDSA private key. It is the responsibility of the gateway shards in `E` to generate these keys. The coordination shard must load-balance this responsibility across the gateway shards in `E` such that no shard is responsible for generating `< N` keys if there is a shard that is responsible for generating `> N+1` keys.

The distributed keygen algorithm used by RenVM allows one shard to generate a secure ECDSA private key for another shard, without anyone in the first shard knowing any of the resulting shares. This means that only one shard is ever able to see shares for any given secure ECDSA private key at any one time.

## References

- [Darknode Registry](./Darknode-Registry)
- [Gateways](./Gateways)
- [Greycore](./Greycore)
- [Hyperdrive](https://github.com/renproject/hyperdrive/wiki)
- [Z0](https://github.com/renproject/z0/wiki)