# Federated Monitoring Stack

These applications are meant to be deployed to Kubernetes using Kustomize.



* **Prometheus**

  * Website: https://prometheus.io/
  * Federation: https://prometheus.io/docs/prometheus/latest/federation/
  * Container Image: https://hub.docker.com/r/prom/prometheus/



* **Kube-State-Metric**

  * Website: https://github.com/kubernetes/kube-state-metrics
  * Container Image: https://quay.io/repository/coreos/kube-state-metrics?tag=latest&tab=tags



* **cAdvisor**

  * Website: https://github.com/google/cadvisor
  * Container Image: https://hub.docker.com/r/google/cadvisor/



* **Node Exporter**

  * Website: https://github.com/prometheus/node_exporter
  * Container Image: https://hub.docker.com/r/prom/node-exporter



* **HAProxy Exporter**

  * Website: https://github.com/prometheus/haproxy_exporter
  * Container Image: https://hub.docker.com/r/prom/haproxy-exporter

<hr>

## Summary

Federated Monitoring Stack is a preconfigured collection of cloud native monitoring tools. It is meant to be used with [TKS-Deploy_Grafana](https://github.com/zimmertr/TKS-Deploy_Grafana) to monitor a TKS platform. But can be used to export metrics retrieved by Kube State Metrics, cAdvisor, and Node Exporter to an external Prometheus server.



Node Exporter and cAdvisor run as Daemonsets with special permissions enabling them to retrieve metrics from the servers running Kubelet and the containers running on them. Kube-State-Metrics scrapes Kubernetes-related metrics using a deployment whose permissions are tied to a ServiceAccount. HAProxy-Exporter runs as a simple deployment used to monitor the HAProxy Load Balancer for the Kubernetes control plane nodes.



These metrics are stored in a Prometheus server with ephemeral memory that has a `/federate` endpoint exposed through a LoadBalancer.

<hr>

## Instructions

1. Example overlays are provided from my environment. Simply create  new overlays using them as an example and deploy the stack to your environment like so:

   ```bash
    vim HAProxy_Exporter/dep.yml 			 # Configure HAProxy-Exporter
    vim Prometheus/files/prometheus.yml # Configure Prometheus
    kustomize build Federated-Monitoring/overlays/example | kubectl apply -f-
   ```



2. You should now be able to query the `/federate` endpoint of your LoadBalancer. For example:

   ```bash
   $> curl http://callisto.sol.milkyway:9090/federate\?match%5B%5D\=%7Bjob%3D\~%22.%2B%22%7D | head -n 5

     % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
   100 14889    0 14889    0     0  29459      0 --:--:-- --:--:-- --:--:-- 29424# TYPE cadvisor_version_info untyped
   cadvisor_version_info{cadvisorRevision="de723a09",cadvisorVersion="v0.30.2",dockerVersion="19.03.13",instance="tks-node-3.sol.milkyway:8080",job="cadvisor",kernelVersion="4.19.0-11-cloud-amd64",osVersion="Alpine Linux v3.7"} 1 1601919222492
   cadvisor_version_info{cadvisorRevision="de723a09",cadvisorVersion="v0.30.2",dockerVersion="19.03.13",instance="tks-node-1.sol.milkyway:8080",job="cadvisor",kernelVersion="4.19.0-11-cloud-amd64",osVersion="Alpine Linux v3.7"} 1 1601919216595
   cadvisor_version_info{cadvisorRevision="de723a09",cadvisorVersion="v0.30.2",dockerVersion="19.03.13",instance="tks-node-2.sol.milkyway:8080",job="cadvisor",kernelVersion="4.19.0-11-cloud-amd64",osVersion="Alpine Linux v3.7"} 1 1601919222037
   # TYPE container_cpu_cfs_periods_total untyped
   100 43969    0 43969    0     0  85745      0 --:--:-- --:--:-- --:--:-- 85709
   ```



3. Configure your external Prometheus server to  scrape this endpoint. For example:

   ```bash
   global:
     scrape_interval:     15s
     evaluation_interval: 15s

   scrape_configs:
     - job_name: 'federate'
       honor_labels: true
       metrics_path: '/federate'

       params:
         match[]:
           - '{job=~".+"}'

       static_configs:
         - targets:
           - 'callisto.sol.milkyway:9090'
   ```

4. The metrics from Kubernetes will now be available in your external Prometheus server.
