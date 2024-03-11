#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --docker-username)
      dockerUsername="${2}"
      shift
      ;;
    --platform)
      platform="$2"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# Docker platform
if [[ $platform == "" ]]; then
  # Default is amd
  platform="amd64"
else
  if [[ $platform != "amd64" && $platform != "arm64" ]]; then
    echo "Platform [--platform] can either be 'amd64' or 'arm64'."
    exit 1
  fi
fi

declare -A simulatorv3
simulatorv3["name"]="simulatorv3"
simulatorv3["imageName"]="${dockerUsername}/${simulatorv3[name]}:latest"

docker build \
  --platform "linux/${platform}" \
  --tag "${simulatorv3["imageName"]}" \
  "."
docker push "${simulatorv3["imageName"]}"