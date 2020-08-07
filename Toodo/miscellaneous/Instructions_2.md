1) Proxmox Demo
2) Harbor Demo
3) Kubernetes Demo
4) MetalLB, NFS Provisioner, Istio Installed already
5) Show NFS Server with dynamic volumes
6) Show Toodo Kustomize project
7) Build container
8) Update container tag
9) Deploy Toodo
10) Create user & task to show DB works properly
    - Create User
    - Log in
    - Create Task
    - Delete User
    - Sign Out

11) Scalability & Session Persistence:
    - Log in
    - Create task
    - Scale Up
    - Open new browser session
    - Show task exists
    - Delete task
    - Show task deleted in other session
    - Scale down

12) App resiliancy & data persistence
    - Log in
    - Create Task
    - kubectl delete pods -n toodo -l app=postgres
    - kubectl delete pods -n toodo -l app=toodo
    - Log in
    - Show task still exists

13) Some ways to improve this:
    - Liveness & Readiness Probes
    - Kustomize Image Overlays
    - Istio mTLS between services
    - SSL Termination for Toodo
    - Canary deployments with Istio
    - Switch from postgres-wait INit to using Readinessprobes
