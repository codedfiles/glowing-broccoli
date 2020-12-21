*RenVM is currently at the beginning of [phase sub-zero](https://github.com/renproject/ren/wiki/Phases).*

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

### Driver

> TODO

### Networking

> TODO

### Consensus and MPC

> TODO

### Multichain

> TODO

## Attestation

Attestation makes it possible for third-parties to cryptographically verify that a node in RenVM is running a signed release of RenVM node software, and is running that software in a secure hardware enclave. This requires trust in:

- Intel SGX (or AMD SEV)
- Ren developers
- Asylo developers

The former can be mitigated by using multiple secure hardware enclaves as support becomes available. The latter two are mitigated by nature of being open-source.

### Safety

> TODO

### Liveliness

> TODO

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