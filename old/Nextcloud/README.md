## Nextcloud

<p align="center">
  <img src="https://raw.githubusercontent.com/zimmertr/Kubernetes-Manifests/master/Nextcloud/screenshot.png" width="800">
</p>

**Summary:**

These manifests are used to deploy an instance of *Nextcloud*. 

Approximate Deployment Time: 20-30 minutes

**Requirements:**  

1. Load Balancer integration so that the Service can expose the pods.
2. NFS Server to which Kubernetes can bind Persistent Volumes.
3. Directory structsure created on the NFS Endpoint you specify in `vars.yml`.
4. Python modules required to use the k8s [Ansible module](https://docs.ansible.com/ansible/latest/modules/k8s_module.html).    
    * pip install openshift kubernetes pyyaml 
    * If you're on MacOS, you might have to do [this](https://github.com/ansible/ansible/issues/43637#issuecomment-443495763) instead.

**Instructions:**  

1. Modify `vars.yml` with parameters according to your environment.
2. Create the necessary directories defined in `vars.yml` on your NFS server.
3. Execute the playbook: `ansible-playbook provision.yml`. 
4. Deployment takes a long time, after 20-30 minutes navigate to https://host.name:/ to access the software. You can check the progress by grabbing the logs from the pod's STDOUT.
5. Set the `Username` and `Password` fields and open the `Storage & database` section. Click `PostgreSQL` and set the following values:
    * Database user: `nextcloud`
    * Database password: `>password in vars.yml<`
    * Database name: `nextcloud`
    * Database host: `postgres:5432`
6. Navigate to https://host.name/login and log in with your new credentials.
7. Optionally select the user icon on the top right and click `Apps`. Select `Disabled Apps` and enable `External Storage`. 
8. Select the user icon on the top right and click `Settings`. Select `External Storages` in the Administration section. Add a new Folder Name with the following configuration:
    * Folder Name: `>Your Choice<`
    * External Storage: `Local`
    * Authentication: `>Your Choice<`
    * Configuration: `/data`
9. If you intend to make Nextcloud available from a different hostname, you will need to make some tweaks to `config.php` located at `/www/nextcloud/config`. Specifically, it is necessary to update the `trusted_domains` array and `overwrite.cli.url` directive as well as add a new `overwritehost` directive. For example, your configuration might look like this afterwards:
    ```
    'trusted_domains' =>
      array (
        0 => 'nextcloud.tjzimmerman.com',
        1 => 'luna.sol.milkyway',
        2 => 'tjzimmerman.dev',
      ),
      'overwrite.cli.url' => 'https://nextcloud.tjzimmerman.com',
      'overwritehost' => 'nextcloud.tjzimmerman.com',
    ```
    After making these changes, it is necessary to recreate the pod so that Nextcloud reloads your configuration changes. I normally accomplish this by running the following two commands:
    ```
    $> kubectl scale -n nextcloud deployment --replicas 0 nextcloud
    $> kubectl scale -n nextcloud deployment --replicas 1 nextcloud
    ```

**TODO:**
1. Evaluate whether or not `postgres_password` supports special characters.
2. Automate changes to `config.php` with optional declarative values in `vars.yml`.

**Deletion:**  

1. You can roll back this deployment with the `delete.yml` playbook: `ansible-playbook delete.yml`.
    * Please note, this will not remove the deployed namespace because I could not be sure you didn't specify an existing namespace. I would hate to delete your `default` for example. So you must manually clean that up. `kubectl delete ns >namespace name<`
