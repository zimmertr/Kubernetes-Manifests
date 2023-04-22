# For some reason Kustomize isn't respecting the namespace field for the helmCharts transformer. So... Shell it is. 
#!/bin/bash

kubectl create ns argo-system
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argo-system -f values.yml
