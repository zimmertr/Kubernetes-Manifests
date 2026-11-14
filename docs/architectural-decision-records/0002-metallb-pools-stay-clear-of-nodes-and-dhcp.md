# 0002. Each MetalLB pool is .100 to .199 of its VLAN, clear of the nodes and of DHCP

- Status: Accepted
- Date: 2026-11-13
- Decider: TJ, after the home network audit for zimmertr/hevy-garmin-sync#62: "we should fix that"
- Issues and PRs: zimmertr/hevy-garmin-sync#62
- Cited in code as: none
- Guide: [`CLAUDE.md`](../../CLAUDE.md), Rules, "MetalLB hands out .100 to .199"

## Context

The pools `vlan40`, `vlan50` and `vlan60` covered .2 to .250 of their VLANs. On VLAN 40 that range holds the Talos nodes and the control plane VIPs, which set their own static addresses (TJs-Kubernetes-Service record 0008), and OPNsense's DHCP range, .200 to .254. Nothing had collided only because every Service pins its address. A Service without a pin could have taken a node's address or one a DHCP client held.

## Decision

Each pool is .100 to .199 of its VLAN, in `istio/metallb/resources/IPAddressPool.yml`. Below .100 belongs to hosts that set their own address; .200 and up belongs to DHCP. Services keep pinning their address inside the pool with `metallb.universe.tf/loadBalancerIPs`.

## Evidence

- 2026-11-13: every pinned address in the repo, enabled or `.disabled`, is between 192.168.40.100 and 192.168.40.150. The live LoadBalancer Services hold .110 to .150. The nodes are .11 to .31 (stable) and .51 and .61 (test), and the VIPs .10 and .50.
- 2026-11-13: OPNsense hands out .200 to .254 on every VLAN.

## Alternatives rejected

- **Keep .2 to .250 and rely on pins**: one unpinned Service could take a node's address and cut it off the network.
- **Exclude only the used addresses**: the pool would need editing each time a node or a reservation is added.

## Consequences

No live address moves, so the change restarts nothing. A Service pinned outside .100 to .199 stays pending until its pin moves inside. The private repo zimmertr/homelab-ipam records the same split.
