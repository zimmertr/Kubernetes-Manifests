# Personal

* [Summary](#summary)
* [Instructions](#instructions)
  * [Kube Prometheus Stack](#kube-prometheus-stack)

<hr>

## Summary

Personal is a collection of my personal applications.

<hr>

## Instructions

### Personal Website

[Personal Website](https://tjzimmerman.com) is my personal website.

1. Modify the Kustomize project as per your needs.

3. Deploy to Kubernetes:
   ```bash
   kubectl kustomize --enable-helm personal-website | kubectl apply -f-
   ```

