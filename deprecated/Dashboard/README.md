# Kubernetes Dashboard

This application is meant to be deployed to Kubernetes using Ansible & Kustomize. 

* **Website**: https://github.com/kubernetes/dashboard
* **Container Image:** https://hub.docker.com/r/kubernetesui/dashboard

<hr>

## Instructions

There are a few ways to deploy the Kubernetes Dashboard using this project.

### The default way:

   ```bash
   kubectl apply -k Dashboard/base
   ```



### Custom ServiceAccount Resource

Deploy the Dashboard and add a new Service Account and ClusterRoleBinding in an overlay to allow you to log into the Dashboard as an administrative user.

   1. Copy `Dashboard/overlays/example` to `Dashboard/overlays/myoverlay` and delete `svc.yml` from the directory. Modify the `kustomization.yml` file in your overlay to not include this file in the `resources` section.

   2. Optionally remove `dep.yml` as well. This is included to provide a single argument to the Dashboard container that prevents it from timing out.

   3. Modify the value for `name` in `crb.yml` and `sa.yml` to refer to your personal username.

   4. Deploy the Dashboard using your custom overlay, retrieve the authentication token, and proxy the Dashboard to your workstation. Be sure to replace `REPLACEME` with your chosen username:

      ```bash
      kubectl apply -k Dashboard/overlays/myoverlay
      kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep REPLACEME | awk '{print $1}')
      kubectl proxy&
      ```



### External LoadBalancer

Deploy the Dashboard and allow external access through a Load Balancer.

   1. Copy `Dashboard/overlays/example` to `Dashboard/overlays/myoverlay` and modify the value for `loadBalancerIp` in `svc.yml` to the IP Address to which you wish to bind the service.

   2. Modify the value for `name` in `crb.yml` and `sa.yml` to refer to your personal username.

   3. Uncomment and update the `subject_alt_name`  variable in `Dashboard/roles/generate_certificates/vars/main.yml`  to be the hostname or IP Address of your load balancer.

   4. Deploy the Dashboard using Ansible , expose it with a Load Balancer, and retrieve the authentication token:

      ```bash
      ansible-playbook deploy_dashboard.yml
      kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep REPLACEME | awk '{print $1}')
      ```