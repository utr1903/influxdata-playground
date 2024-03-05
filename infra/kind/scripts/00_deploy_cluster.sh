#!/bin/bash

clusterName="influx"

kind create cluster \
  --name $clusterName \
  --config ../config/kind-config.yaml \
  --image=kindest/node:v1.28.0
