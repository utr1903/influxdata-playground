#!/bin/bash

# # Add repo
# helm repo add influxdata https://helm.influxdata.com/
# helm repo update

# chronograf
declare -A chronograf
chronograf["name"]="chronograf"
chronograf["namespace"]="test"
chronograf["port"]=80

###################
### Deploy Helm ###
###################

# chronograf
helm upgrade ${chronograf[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace=${chronograf[namespace]} \
  --set nameOverride=${chronograf[name]} \
  "influxdata/chronograf"
