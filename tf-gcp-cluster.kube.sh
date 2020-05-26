#!/usr/bin/env bash
#
# Uses the output of the terraform to create a docker volume (named by the caller) with
# configuration for kubectl along with the project service account credentials.

USAGE="Usage: tf-gcp-cluster.kube.sh <tf-volume>"

# Exit on errors and log commands
set -e

# Function which will die with an error message.
function die() {
    echo -e "\e[31m" $@ "\e[39m" >&2; exit 1
}

TF_VOLUME=$1
[ -z "${TF_VOLUME}" ] && die $USAGE 

# TF outputs
CLUSTER_NAME=$(./tf-gcp-cluster.sh $TF_VOLUME output cluster_name)
CLUSTER_ZONE=$(./tf-gcp-cluster.sh $TF_VOLUME output cluster_zone)
PROJECT_ID=$(./tf-gcp-cluster.sh $TF_VOLUME output project_id)

# configuration script for kubectl
cat <<EOF >kube.sh
gcloud config set auth/credential_file_override /root/.kube/service_account_credentials.json
gcloud config set project $(echo $PROJECT_ID | tr -d '[:space:]')
gcloud container clusters get-credentials $(echo $CLUSTER_NAME | tr -d '[:space:]') \
  --zone=$(echo $CLUSTER_ZONE | tr -d '[:space:]')
EOF

chmod +x kube.sh

# copy the configuration to the volume
docker run --rm -e HISTFILE=/root/.kube/.bash_history \
  -v $TF_VOLUME-kube:/root/.kube -v $PWD:/project alpine sh -c 
  "cp /project/service_account_credentials.json /project/kube.sh /root/.kube/"

rm kube.sh
