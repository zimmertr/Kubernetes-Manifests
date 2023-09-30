#!/bin/bash

kubectl kustomize --enable-helm . | sed 's/release-name-//g' | kubectl apply -f-
