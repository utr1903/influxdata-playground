#!/bin/bash

# # Add repo
helm repo add influxdata https://helm.influxdata.com/
helm repo update

# influxdb
declare -A influxdb
influxdb["name"]="influxdb"
influxdb["namespace"]="test"
influxdb["replicas"]=2
influxdb["port"]=8086
influxdb["password"]="admin123"
influxdb["token"]="admin123"

###################
### Deploy Helm ###
###################

# influxdb
helm upgrade ${influxdb[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace=${influxdb[namespace]} \
  --set fullnameOverride=${influxdb[name]} \
  --set replicas=${influxdb[replicas]} \
  --set adminUser.password=${influxdb[password]} \
  --set adminUser.token=${influxdb[token]} \
  --set service.port=${influxdb[port]} \
  "influxdata/influxdb2"
