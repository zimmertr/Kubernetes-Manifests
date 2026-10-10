# Misc

* [Summary](#summary)

<hr>

## Summary

Misc is a collection of miscellaneous applications, deployed by Argo CD:

| Application                                                  | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [Kubelet CSR Approver](https://github.com/postfinance/kubelet-csr-approver) | Approves the kubelet serving certificate requests that Cilium and Metrics Server wait on |
| [Mountaineers Activity Scraper](https://github.com/zimmertr/Mountaineers-Activity-Scraper) | A CronJob that runs the scraper once a day. It needs a Google Cloud credentials secret, see [Secrets and Volumes](../README.md#secrets-and-volumes) in the main README |

Heimdall and Homepage are disabled. Homepage seeds its volumes from `homepage/files/{configs,icons,images}` on init, so update those before turning it back on.
