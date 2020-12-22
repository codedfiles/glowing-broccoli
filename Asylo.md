*RenVM is currently at the beginning of [phase sub-zero](https://github.com/renproject/ren/wiki/Phases). This document is a work-in-progress.*

0. [Too Long; Didn't Read](#tldr)
1. [Design](#design)
    1. [Driver](#driver)
    2. [Networking](#networking)
    3. [Consensus and MPC](#consensus-and-mpc)
    4. [Multichain](#multichain)
2. [Attestation](#attestation)
    1. [Safety](#safety)
    2. [Liveliness](#liveliness)
3. [Support](#support)
4. [References](#references)

## Design

A brief overview of the requirements:

- Nodes would be required to run within a secure hardware enclave. Just as nodes currently require other nodes to have their identities bonded by 100K REN, so too would they require a success remote attestation.
- Nodes would be required to communicate through Asylo's gRPC security stack. This provides enclave-to-enclave protection between remote enclaves.
- Nodes would be required to run their underlying blockchain node infrastructure within a secure hardware enclave.
- Nodes would be required to store all data in a way that is only accessible from the enclave (i.e. it is encrypted at rest).

These requirements can be built into the official implementation of RenVM. This means that as part the attestation which verifies that a node is (a) running within an enclave, and (b) running an official implementation of RenVM, these requirements are able to be verified remotely.

### Driver

Asylo, and its examples, are dominantly written in C++, and the current implementation of RenVM is written in Go. The simplest way to integrate Asylo would be to boot in Go, use a foreign-function-interface to call out to the required C++ code that configures and drives the enclave (using Asylo libraries). The C++ code running in the enclave would return control flow back to Go to run the rest of the application logic. This should minimise the integration requirements for porting the current implementation RenVM to run in secure hardware enclaves.

The [POSIX runtime](https://asylo.dev/docs/reference/runtime.html#posix) provided by Asylo has everything we need for storage and networking.

### Networking

RenVM nodes would use the [Enclave Key Exchange Protocol (EKEP)](https://asylo.dev/docs/concepts/ekep.html) to establish secure enclave-to-enclave connections with one another. This connection would be the conncetion through which all network messages between these nodes is sent. However, before sending any messages on this connection, the nodes would engage in a remote attestation procedure, to verify that the remote peer is (a) running in a secure hardware enclave, and (b) is running an official RenVM node binary.

The biggest impact on the current implementation of RenVM would be to its networking layer: Airwave. Currently, Airwave uses its own custom messaging protocol over TCP (using [surge](https://github.com/renproject/surge) for serialisation), with a custom handshake for establishing secure peer-to-peer connection. However, it is designed to a variety of different transport layers and handshakes. In principle, it should be possible to add support for gRPC to the Airwave transport interface, and the support for EKEP to its handshake interface. The Asylo project also comes with a number of examples of how to use gRPC in the context of secure hardware enclaves:

- [gRPC Server](https://github.com/google/asylo-examples/tree/master/grpc_server)
- [Secure gRPC Server](https://github.com/google/asylo-examples/tree/master/secure_grpc)

The [POSIX runtime](https://asylo.dev/docs/reference/runtime.html#posix) provided by Asylo has everything we need for storage and networking.

### Consensus and MPC

Perhaps the most critical part of the RenVM codebase is its [consensus](https://github.com/renproject/hyperdrive) and [multi-party computation](https://github.com/renproject/mpc) implementations. However, these libraries have intentionally been built with no dependency on specific networking or storage implementations. Where required, they define interfaces that are expected to be implemented by the user of the library. This should make it trivial to port these implementations to run within secure hardware enclaves using Asylo.

### Multichain

The majority of RenVM nodes use the Multichain API for accessing the underlying blockchains. Google Cloud supports managed Kubernetes clusters running on Shielded VMs. This should allow the Multichain API to run within secure hardware enclaves, reducing the risk of malicious behaviour by those operating the API. It is also possible for RenVM nodes to use stateless SPV proofs (and other log-scale proof systems) to verify transaction information from blockchains without the need of a remote API.

## Attestation

Attestation makes it possible for third-parties to cryptographically verify that a node in RenVM is running a signed release of RenVM node software, and is running that software in a secure hardware enclave. This requires trust in:

- Intel SGX (or AMD SEV)
- Ren developers
- Asylo developers

The former can be mitigated by using multiple secure hardware enclaves as support becomes available. The latter two are mitigated by nature of being open-source.

### Safety

The Byzantine fault-tolerant consensus mechanism used by RenVM is only able to within up to (but not including) 1/3rd of its nodes behaving maliciously. In the case where nodes are running in an Intel SGX hardware enclave, third-parties can perform an attestation procedure with any/all of the nodes to verify that they are in fact running in an enclave, and are actually running an official implementation of the RenVM. This is also a process done by the nodes themselves before admitting new nodes into the network, and would in itself be part of the official implementation of RenVM. An argument by induction shows that, if at any point more than 2/3rds of nodes are verifiable running the official implementation in an enclave, the safety of the network can never be compromised (unless the secure hardware enclaves themselves are compromised).

### Liveliness

Although attestation procedures can be used to verify the nodes are running in a secure hardware enclave, and are running an official release, this cannot be used to ensure liveliness. It is always possible that a node is offline for a variety of reasons: intentionally attempting to disrupt network activity, in a temporary network partition, or even a fault in the underlying hardware.

Assuming the security of secure hardware enclave, liveliness becomes the primary security concern of the network. Funds in RenVM would not be able to be stolen (since nodes would not be able to run software that has this capability). Liveliness of funds can be easily guaranteed: all gateways into which funds are deposited would have a secondary condition under which the funds can be spent. This secondary condition would allow the Ren core developer team, or a multi-sig controlled by multiple semi-trusted parties, to spend funds after 1 week. Because funds are rotated after 24 hours, the 1 week delay guarantees that the semi-trusted parties cannot compromise funds when RenVM is lively.

This mechanism only ever needs to be engaged in the case where a shard becomes inactive for an entire week (a severe liveliness failure). This would require an attacker to take down 1/3rd of a shard for an entire week.

## Support

Asylo supports all of the features required on Intel SGX. The Ren core developer team could provide resources to help with adding support for other secure hardware enclave implementations as they become available. This should be prioritised, because it reduces reliance on one hardware provider. Google and Azure both offer confidential computing platforms that give users access to secure hardware enclaves.

## References

Further reading material:

- [Asylo](https://asylo.dev)
- [Trusted execution environments](https://en.wikipedia.org/wiki/Trusted_execution_environment)
- [AMD SEV](https://developer.amd.com/sev)
- [Intel SGX](https://www.intel.com/content/www/us/en/architecture-and-technology/software-guard-extensions.html)
- [Intel SGX Explained](https://eprint.iacr.org/2016/086.pdf)
- [Intel SGX hardware release enclaves](https://asylo.dev/docs/guides/sgx_release_enclaves.html)
- [Secure gRPC Example](https://asylo.dev/docs/guides/secure_grpc.html)