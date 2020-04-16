REN is the ERC20 token used to bond Darknodes to RenVM. To register a valid Darknode identity, an operator must deposit 100000 REN tokens into the Darknode Registry contract. This is a good behaviour bond, and can be slashed if the Darknode behaves maliciously, or if the Darknode is part of a shard that behaves maliciously. This provides an incentive for the Darknode operator not to participate in malicious activity, and to encourage the same behaviour in other Darknode operators too.

## Safety and Capital Efficiency

To better understand the utility of REN, we need to discuss the capital efficiency of decentralised interoperability protocol. But, it ultimately comes down *safety* and *efficiency*.

> Using REN means that RenVM does not need to introduce a mechanism for liquidating Darknodes; this would expose them, and the users of RenVM, to market volatility risk. Furthermore, as the total value locked in RenVM increases, the capacity for more total value locked also increases without requiring the injection of more capital (allowing RenVM to easily scale to large amounts of liquidity).

First, it is important to recognise that in any trust-less interoperability protocol, some amount of value must be bonded by the nodes powering the protocol. Otherwise, there can exist large financial incentives for the nodes to compromise the protocol, stealing more value from it than they will lose from their bonds. There is no known way to completely prevent theft in a trust-less interoperability protocol, so the only option is to make it very difficult and unprofitable to do so. In practice, different trust-less interoperability protocols often need the total value bonded to exceed the total value locked by different multiples. The exact multiple is not particularly interesting. However, what is important is how the multiple is maintained in the face of market volatility.

### Market Capitalisation and Token Holder Distribution

Consider an example protocol, *π*, that wants to send $X of BTC to Ethereum and requires its nodes to bond at least $Y worth of value. Imagine that this hypothetical *π* uses ETH for bonding. Whenever someone wants to send $X of BTC to Ethereum, the nodes powering *π* must bond at least $Y of ETH. There are two major advantages to this: *market capitalisation* and *token holder distribution*.

Market capitalisation refers to the total market value of ETH — $15.7B at the time of writing — and token holder distribution refers to the number of individuals that hold a reasonable quantity of ETH. By using ETH, *π* can be sure that (a) there are plenty of people able to participate as nodes and (b) there is $15.7B worth of ETH that can be used for bonding. In theory, this means *π* could be holding on the magnitude of $15.7B worth of BTC at any one point in time.

### Volatile Bonding

However, in practice, this does not work, because the value of ETH is not correlated with the use of *π*. Demand could increase, but the ETH price could stay the same or drop. Demand could stay the same, but the ETH price could drop. Demand could even drop, but the ETH price could drop more. In general, as demand for *π* fluctuates, or as the ETH price fluctuates, the *π* nodes must constantly adjust the size of their ETH bonds.

In all of the situations listed above, the *π* nodes would have to increase their bonds or else *π* would become insecure. Furthermore, *π* would need a way to force nodes to do this. The only known solution to this is liquidation; taking away the bond of the *π* nodes if they fail to keeping bonding enough value. Not only does this introduce massive risk for the nodes, but liquidation mechanisms have been known to fail during times of market volatility, and usually require the use of semi-centralised pricing oracles.

### Competitive Bonding

ETH is a highly competitive form of collateral. Our hypothetical *π* protocol would need to convince people to bond ETH into *π* instead of doing something else with that ETH. For example, staking on Ethereum itself and earning block rewards, lending ETH and earning interest, or collateralising Dai and earning interest. Failure to remain competitive results in instability for the actual capacity that *π* can maintain.

### Capital Efficiency with a Native Token

By using REN, RenVM is able to avoid these disadvantages.

The sole use of REN is for bonding Darknodes to RenVM, and as such the price of REN is tightly coupled to the fees earned by RenVM. Owning 100000 REN allows you to register a Darknode, earn fees, and yield %ROI on your REN. As more assets are moved back-and-forth between chains, RenVM earns more fees, the price of REN increases, the total bond value of REN increases, and there is more capacity for more assets. Put another way, an increased demand for the system naturally improves RenVM’s ability to meet that demand without requiring Darknode to post more collateral, or expose themselves to liquidation risks.

To keep the bonded value above its target, RenVM is able to adjust its fees. This would have no impact on the bonded value if RenVM was to use a non-native token. By adjusting fees, RenVM can lower demand, but also increase the value of REN. Using this can completely avoid the need for liquidation mechanisms.

Lastly, there is no competitive collateral market for REN. The only way to earn yield on REN is to register a Darknode and help power RenVM. You cannot use REN as collateral, and people will only borrow it if the returns for running a Darknode are higher than the interest rate (and this would imply that the lender would get more profit by running a Darknode themselves).