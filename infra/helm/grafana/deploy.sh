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

# # Add repo
# helm repo add grafana https://grafana.github.io/helm-charts
# helm repo update

# influxdbv3
declare -A influxdbv3
influxdbv3["bucket"]="test"
influxdbv3["address"]="${influxdbAddress}"
influxdbv3["token"]="${influxdbToken}"

# grafana
declare -A grafana
grafana["name"]="grafana"
grafana["namespace"]="test"

###################
### Deploy Helm ###
###################

# dashboard
kubectl create configmap \
  -n ${grafana[namespace]} \
  grafana-dashboard \
  --from-file=dashboard.json 

# grafana
helm upgrade ${grafana[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace=${grafana[namespace]} \
  --set adminUser="admin" \
  --set adminPassword="admin1234" \
  --set datasources."datasources\.yaml".apiVersion=1 \
  --set datasources."datasources\.yaml".datasources[0].name=InfluxDB_v3 \
  --set datasources."datasources\.yaml".datasources[0].type=influxdb \
  --set datasources."datasources\.yaml".datasources[0].access=proxy \
  --set datasources."datasources\.yaml".datasources[0].url="${influxdbv3[address]}" \
  --set datasources."datasources\.yaml".datasources[0].jsonData.dbName="${influxdbv3[bucket]}" \
  --set datasources."datasources\.yaml".datasources[0].jsonData.version="SQL" \
  --set datasources."datasources\.yaml".datasources[0].jsonData.httpMode="POST" \
  --set datasources."datasources\.yaml".datasources[0].secureJsonData.token="${influxdbv3[token]}" \
  --set dashboardProviders."dashboardproviders\.yaml".apiVersion=1 \
  --set dashboardProviders."dashboardproviders\.yaml".providers[0].name="default" \
  --set dashboardProviders."dashboardproviders\.yaml".providers[0].orgId=1 \
  --set dashboardProviders."dashboardproviders\.yaml".providers[0].folder="" \
  --set dashboardProviders."dashboardproviders\.yaml".providers[0].type="file" \
  --set dashboardProviders."dashboardproviders\.yaml".providers[0].disableDeletion="false" \
  --set dashboardProviders."dashboardproviders\.yaml".providers[0].editable="true" \
  --set dashboardProviders."dashboardproviders\.yaml".providers[0].updateIntervalSeconds=10 \
  --set dashboardProviders."dashboardproviders\.yaml".providers[0].options.path="/var/lib/grafana/dashboards/default" \
  --set dashboardsConfigMaps.default="grafana-dashboard" \
  --version "7.3.6" \
  "grafana/grafana"
