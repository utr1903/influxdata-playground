#!/bin/bash

# Add repo
helm repo add influxdata https://helm.influxdata.com/
helm repo update

# chronograf
declare -A chronograf
chronograf["name"]="chronograf"
chronograf["namespace"]="test"
chronograf["port"]=80

###################
### Deploy Helm ###
###################

# dashboard
kubectl create configmap \
  -n ${chronograf[namespace]} \
  chronograf-dashboard \
  --from-file=Playground.dashboard 

# chronograf
helm upgrade ${chronograf[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace=${chronograf[namespace]} \
  --set nameOverride=${chronograf[name]} \
  --set volumes[0].name=dashboard \
  --set volumes[0].configMap.name=dashboard \
  --set volumeMounts[0].name=dashboard \
  --set volumeMounts[0].mountPath=/usr/share/chronograf/resources \
  "influxdata/chronograf"
