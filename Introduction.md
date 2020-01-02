RenVM is a [Byzantine fault tolerant](https://en.wikipedia.org/wiki/Byzantine_fault) virtual machine — replicated over a network of thousands of machines — that can run computations and store/replicate data in secret. Inputs, outputs, and data in RenVM are kept hidden from everyone, even the machines that power it. RenVM uses this secret computation/storage to implement **general purpose interoperability** between new and existing blockchains. It defines special "secret contracts" that can be used to send digital assets, and generic data, from one blockchain to another (see [Gateways](https://github.com/renproject/ren/wiki/Gateways)).

RenVM empowers developers to build Ethereum smart contracts that use Bitcoin, Bitcoin Cash, and ZCash (see [Supported Blockchains](https://github.com/renproject/ren/wiki/Supported-Blockchains)). By doing so, users are able to access all of the trustless and permissionless financial services offered by [Ethereum DeFi](https://defiprime.com) using digital assets that are not native to Ethereum. For example: RenVM enables everyone to use BTC for swapping, trading, leveraging, lending, and collateralisation on Ethereum.

## Principles

RenVM is designed and developed under three guiding principles:

- **Decentralisation**
  RenVM cannot be controlled or censored by a central authority, and is open to everyone without the need for permission. Anyone can interact with the virtual machine, anyone move assets and data from one blockchain to another, and anyone can contribute their resources to powering the virtual machine in exchange for a reward.
- **Byzantine Fault Tolerance**
  RenVM is designed to be trustless. It is designed to guarantee its safety and liveliness properties even in the presence of malicious adversaries. Up to 1/3rd of participants can behave arbitrarily and RenVM will continue to function as expected. Furthermore, participants are economically incentivised to behave (see [Darknode Slasher](https://github.com/renproject/ren/wiki/Darknode-Slahser)).
- **Liveliness**
  RenVM is resilient to failures in the underlying machines. Faults in less than 2/3rd of the machines cannot cause loss of data, and faults in less than 1/3rd of the machines cannot halt progress. This ensures that RenVM can function as expected, even in a distributed and disrupted network.

## How It Works

RenVM can be broken down into three fundamental components:

- Byzantine fault tolerant [consensus](https://github.com/renproject/ren/wiki/Consensus),
- Secure multi-party computation used for [execution](https://github.com/renproject/ren/wiki/Execition), and
- Interoperability [gateways](https://github.com/renproject/ren/wiki/Gateways).

[Consensus](https://github.com/renproject/ren/wiki/Consensus) is used to agree on which RenVM transactions will be executed, and in what order. Like other decentralised networks, RenVM transactions respresents messages sent to contracts to execute trustless application logic. RenVM achieves Byzantine fault tolerant consensus using a modified version of the Tendermint consensus algorithm: [Hyperdrive](https://github.com/renproject/hyperdrive/wiki). It is designed to solve some of the outstanding problems with the Tendermint consensus algorithm, and to be appropriate for use alongside [secure multi-party computations](https://en.wikipedia.org/wiki/Secure_multi-party_computation). The implementation is designed to be minimal and easy to audit.

[Execution](https://github.com/renproject/ren/wiki/Execution) of RenVM transactions happens using a newly developed secure multi-party computation algorithm: RZL sMPC. Using this algorithm, RenVM contracts are able to keep theirs inputs/outputs/state secret. These "secret contrats" are the bedrock of what makes RenVM powerful, enabling secret computations on secret data. RZL sMPC has the same safety/liveliness properties as Hyperdrive, making them natural companions. It has been implemented as part of a more general purpose virtual machine, [z0](https://github.com/renproject/z0), which has also been designed to be minimal and easy to audit. A reviewed paper describing RZL sMPC, and proving its safety/liveliness, will be released soon.

[Gateways](https://github.com/renproject/ren/wiki/Gateways) are special built-in RenVM contracts that provide interoperability between new and existing blockchains. For example, the `BTCEthereum` gateway allows users to send BTC from the Bitcoin blockchain to the Ethereum blockchain (and back again). This is done by generating and keeping ECDSA private keys in secret. No-one can see the private keys, and no-one can use them without consensus from the network. Every [epoch](), gateways periodically shuffle and rotate these ECDSA private keys to protect against adaptive adversaries. For now, these are the only contracts that are supported by RenVM.​

## Examples

[Roundabout](https://roundabout.exchange) is a simple dapp that allows users to send BTC to/from Ethereum. While BTC is on Ethereum, it also allows users to trade it using [Uniswap](https://uniswap.exchange/swap?inputCurrency=0x88c64a7d2ecc882d558dd16abc1537515a78bb7d?outputCurrency=0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48?theme=light).

[ChaosDEX](https://chaosdex.renproject.io) is a Uniswap-like DEX that supports BTC, BCH, ZEC, and DAI. It is built as a demonstration of what is possible with RenVM, and explicitly breaks down every step so that developers can better understand what is happening under-the-hood.

## Community

Ask questions, give us feedback, and learn more about the project:

- [Telegram](https://t.me/renproject)
- [Reddit](https://reddit.com/r/RenProject)

Contribute to the design, and get involved in technical discussions:

- [GitHub](https://github.com/renproject/ren/issues)