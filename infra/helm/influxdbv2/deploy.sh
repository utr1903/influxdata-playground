#!/bin/bash

# Add repo
helm repo add influxdata https://helm.influxdata.com/
helm repo update

# influxdbv2
declare -A influxdbv2
influxdbv2["name"]="influxdbv2"
influxdbv2["namespace"]="test"
influxdbv2["port"]=8086
influxdbv2["password"]="admin123"
influxdbv2["token"]="admin123"

###################
### Deploy Helm ###
###################

# influxdbv2
helm upgrade ${influxdbv2[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace=${influxdbv2[namespace]} \
  --set fullnameOverride=${influxdbv2[name]} \
  --set adminUser.password=${influxdbv2[password]} \
  --set adminUser.token=${influxdbv2[token]} \
  --set service.port=${influxdbv2[port]} \
  "influxdata/influxdb2"
