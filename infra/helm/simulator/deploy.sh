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

# influxdb
declare -A influxdb
influxdb["name"]="influxdb"
influxdb["namespace"]="test"
influxdb["replicas"]=2
influxdb["port"]=8086
influxdb["organization"]="influxdata"
influxdb["bucket"]="default"
influxdb["password"]="admin123"
influxdb["token"]="admin123"

# simulator
declare -A simulator
simulator["name"]="simulator"
simulator["imageName"]="${dockerUsername}/${simulator[name]}:latest"
simulator["namespace"]="test"
simulator["replicas"]=1
simulator["port"]=8080

###################
### Deploy Helm ###
###################

# simulator
helm upgrade ${simulator[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace=${simulator[namespace]} \
  --set imageName=${simulator[imageName]} \
  --set imagePullPolicy="Always" \
  --set name=${simulator[name]} \
  --set replicas=${simulator[replicas]} \
  --set port=${simulator[port]} \
  --set influxdb.organization="${influxdb[organization]}" \
  --set influxdb.bucket="${influxdb[bucket]}" \
  --set influxdb.address="http://${influxdb[name]}.${influxdb[namespace]}.svc.cluster.local:${influxdb[port]}" \
  --set influxdb.token="${influxdb[token]}" \
  "./chart"
