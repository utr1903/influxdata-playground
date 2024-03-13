#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
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
influxdbv3["bucket"]="test"
influxdbv3["address"]="${influxdbAddress}"
influxdbv3["token"]="${influxdbToken}"

# otelcollector
declare -A otelcollector
otelcollector["name"]="otelcollector"
otelcollector["imageName"]="otel/opentelemetry-collector-contrib:0.96.0"
otelcollector["namespace"]="test"
otelcollector["replicas"]=1

###################
### Deploy Helm ###
###################

# otelcollector
helm upgrade ${otelcollector[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace=${otelcollector[namespace]} \
  --set imageName=${otelcollector[imageName]} \
  --set imagePullPolicy="Always" \
  --set name=${otelcollector[name]} \
  --set replicas=${otelcollector[replicas]} \
  --set influxdb.endpoint="${influxdbv3[address]}" \
  --set influxdb.bucket="${influxdbv3[bucket]}" \
  --set influxdb.token="${influxdbv3[token]}" \
  "./chart"
