# Demo

## Summary

A short demo of Toodo project



## Instructions

1. Deploy a Kubernetes Cluster to Proxmox using Bootstrap Kubernetes with QEMU

   ```bash
   ansible-playbook -i inventory.ini site.yml
   ```

   

2. Deploy a Load Balancer controller to expose Ingress

   ```bash
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
    kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
    
   cat <<EOF | kubectl apply -f-
   apiVersion: v1
   kind: ConfigMap
   metadata:
     namespace: metallb-system
     name: config
   data:
     config: |
       address-pools:
       - name: default
         protocol: layer2
         addresses:
         - 192.168.40.150-192.168.40.250
   EOF
   ```

   1. I used to use MetalLB in BGP mode so I could put pods in DMZ vlans. However, this was problematic as it interrupted virtual switching and tied my pod network to the throughput limitations of my router (Ubiquti Edgerouter Lite / 1Gbps)

3. Deploy a dynamic Persistent Volume provisioner

   ```bash
   ansible-playbook -i inventory.ini playbooks/optional/deploy_nfs_provisioner.yml
   ```

4.  Deploy Istio

    ```
    ansible-playbook Istio/deploy_istio.yml
    ```

 5.  Deploy & Secure Harbor

         1.  https://harbor.tjzimmerman.dev
         2.  Create a Harbor Project

 6.  Build a Toodo container using a tweaked Dockerfile, push it to Harbor

 7.  Deploy Toodo using Kustomize

     ```bash
     kubectl create ns toodo
     
     kubectl create secret docker-registry registry-secret --docker-server=harbor.tjzimmerman.dev --docker-username=admin --docker-password=P@ssw0rd1! --docker-email=tj@tjzimmerman.com -n toodo
     
     kustomize build Toodo/overlays/example | kubectl apply -f-
     ```

 8.  Code walkthrough while app comes up

         1.  Kustomization.yml
         2.  Show Base & Overlay
         3.  Istio & Secrets
         4.  Show Statefulset and deployment
         5.  Show job

 9.  Demonstrate app functionality

         1.  Create user account
         2.  Create Task
         3.  Delete Task
         4.  Sign out

 10.  Scale app & demonstrate functionality

          1.  Sign in, create task
          2.  Open new browser window, sign in, show task exists 
          3.  Sign out

 11.  Show resilliancy

          Delete all pods, show app returns with data 
          
              ```bash
              kubectl delete pods -n toodo -l app=postgres
              kubectl delete pods -n toodo -l app=toodo
              ```
          
          2.  Log back in, show item still exists 
          
                  1.  Whoops, but you get the idea. 
                  2.  User account still exists for example. 
                  3.  Actually I'll stay signed in to show session persistance between scaling frontend servers 
                  4.  Still logged in, immediatly got placed on last remaining live pod 

12. Show Locust Results