#!/usr/bin/env bash
#
# Uses the output of the terraform to create a docker volume (named by the caller) with
# configuration for kubectl along with the project service account credentials.

USAGE="Usage: create-cluster-volume.sh <tf-volume>"

# Exit on errors and log commands
set -e

# Function which will die with an error message.
function die() {
    echo -e "\e[31m" $@ "\e[39m" >&2; exit 1
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

TF_VOLUME=$1
[ -z "${TF_VOLUME}" ] && die $USAGE 

# TF outputs
CLUSTER_NAME=$($DIR/terraform.sh $TF_VOLUME output cluster_name)
CLUSTER_ZONE=$($DIR/terraform.sh $TF_VOLUME output cluster_zone)
PROJECT_ID=$($DIR/terraform.sh $TF_VOLUME output project_id)

# configuration script for kubectl
cat <<EOF >init.sh
gcloud config set project $(echo $PROJECT_ID | tr -d '[:space:]')
gcloud config set auth/credential_file_override /cluster/service_account_credentials.json
gcloud container clusters get-credentials $(echo $CLUSTER_NAME | tr -d '[:space:]') \
  --zone=$(echo $CLUSTER_ZONE | tr -d '[:space:]')
EOF

chmod +x init.sh

# copy the configuration to the volume
docker run --rm -v $TF_VOLUME-cluster:/cluster \
  -v $PWD:/project alpine sh -c \
  "cp /project/service_account_credentials.json /project/init.sh /cluster"

rm init.sh
