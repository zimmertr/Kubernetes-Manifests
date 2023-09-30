#!/bin/bash

kubectl kustomize --enable-helm . | kubectl apply -f-

