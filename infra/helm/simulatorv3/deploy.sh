#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --docker-username)
      dockerUsername="${2}"
      shift
      ;;
    --influxdb-address)
      influxdbAddress="${2}"
      shift
      ;;
    --influxdb-token)
      influxdbToken="${2}"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# influxdbv3
declare -A influxdbv3
influxdbv3["replicas"]=2
influxdbv3["port"]=8086
influxdbv3["organization"]="influxdata"
influxdbv3["bucket"]="test"
influxdbv3["address"]="${influxdbAddress}"
influxdbv3["token"]="${influxdbToken}"

# simulatorv3
declare -A simulatorv3
simulatorv3["name"]="simulatorv3"
simulatorv3["imageName"]="${dockerUsername}/${simulatorv3[name]}:latest"
simulatorv3["namespace"]="test"
simulatorv3["replicas"]=1
simulatorv3["port"]=8080

###################
### Deploy Helm ###
###################

# simulatorv3
helm upgrade ${simulatorv3[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace=${simulatorv3[namespace]} \
  --set imageName=${simulatorv3[imageName]} \
  --set imagePullPolicy="Always" \
  --set name=${simulatorv3[name]} \
  --set replicas=${simulatorv3[replicas]} \
  --set port=${simulatorv3[port]} \
  --set influxdb.organization="${influxdbv3[organization]}" \
  --set influxdb.bucket="${influxdbv3[bucket]}" \
  --set influxdb.address="${influxdbv3[address]}" \
  --set influxdb.token="${influxdbv3[token]}" \
  "./chart"
