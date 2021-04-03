# NextCloud

This application is meant to be deployed to Kubernetes using Kustomize.

<hr>

## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build NextCloud/overlays/example | kubectl apply -f-
   ```

Don't forget to update the kustomizations and password files according to your environment.



After deploying, NextCloud will wait for Postgres to start before initializing. Nextcloud will create any necessary files on your persistent volumes at this time. Unfortunately, it doesn't correctly set their permissions. I have added a second init-container for this purpose. Simply kill the pod to trigger it to fix the filesystem permissions. The logs that indicate this look like:

```bash
Configuring Redis as session handler
Initializing nextcloud 21.0.0.18 ...
Initializing finished
New nextcloud instance
Installing with PostgreSQL database
starting nextcloud installation
Console has to be executed with the user that owns the file config/config.php
Current user id: 33
Owner id of config.php: 0
Try adding 'sudo -u #0' to the beginning of the command (without the single quotes)
If running with 'docker exec' try adding the option '-u 0' to the docker command (without the single quotes)
```

