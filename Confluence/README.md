# Confluence

This application is meant to be deployed to Kubernetes using Kustomize. 

* **Website**: https://www.atlassian.com/software/confluence
* **Container Image:** https://hub.docker.com/r/atlassian/confluence-server/

<hr>

## Notes

* Confluence anticipates that all volume mounted files be owned by UID and GID 2002. Be sure to set this before deploying. 
* `postgres_password` most be populated before deploying. The value for both should be the same as they are both unique environment variable that their respective container is hardcoded to receive.

<hr>

## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build Confluence/overlays/example | kubectl apply -f-
   ```
