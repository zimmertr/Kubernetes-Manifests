# Media

* [Summary](#summary)

<hr>

## Summary

Media is a collection of entertainment applications, deployed by Argo CD:

| Application                                         | Description                  |
| --------------------------------------------------- | ---------------------------- |
| [Jellyfin](https://jellyfin.org/)                   | A media streaming server     |
| [ruTorrent](https://github.com/Novik/ruTorrent)     | A bittorrent client          |
| [Sonarr](https://sonarr.tv/)                        | A television collection manager |

Plex, Radarr and Tautulli are disabled. If you turn Plex back on, update its claim token from https://plex.tv/claim first.

Their config lives on statically provisioned volumes, see [Secrets and Volumes](../README.md#secrets-and-volumes) in the main README.
