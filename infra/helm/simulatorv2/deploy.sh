#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --docker-username)
      dockerUsername="${2}"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# influxdbv2
declare -A influxdbv2
influxdbv2["name"]="influxdbv2"
influxdbv2["namespace"]="test"
influxdbv2["replicas"]=2
influxdbv2["port"]=8086
influxdbv2["organization"]="influxdata"
influxdbv2["bucket"]="default"
influxdbv2["password"]="admin123"
influxdbv2["token"]="admin123"

# simulatorv2
declare -A simulatorv2
simulatorv2["name"]="simulatorv2"
simulatorv2["imageName"]="${dockerUsername}/${simulatorv2[name]}:latest"
simulatorv2["namespace"]="test"
simulatorv2["replicas"]=1
simulatorv2["port"]=8080

###################
### Deploy Helm ###
###################

# simulatorv2
helm upgrade ${simulatorv2[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace=${simulatorv2[namespace]} \
  --set imageName=${simulatorv2[imageName]} \
  --set imagePullPolicy="Always" \
  --set name=${simulatorv2[name]} \
  --set replicas=${simulatorv2[replicas]} \
  --set port=${simulatorv2[port]} \
  --set influxdb.organization="${influxdbv2[organization]}" \
  --set influxdb.bucket="${influxdbv2[bucket]}" \
  --set influxdb.address="http://${influxdbv2[name]}.${influxdbv2[namespace]}.svc.cluster.local:${influxdbv2[port]}" \
  --set influxdb.token="${influxdbv2[token]}" \
  "./chart"
