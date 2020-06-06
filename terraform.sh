#!/usr/bin/env bash
#
# Executes terraform in a container, storing any state/config in a volume named by the caller.

USAGE="Usage: terraform.sh <tf-volume> ..."

# Exit on errors and log commands
set -xe

# Function which will die with an error message.
function die() {
    echo -e "\e[31m" $@ "\e[39m" >&2; exit 1
}

TF_VOLUME=$1
[ -z "${TF_VOLUME}" ] && die $USAGE 

shift

docker run --interactive --tty --rm \
  -e GOOGLE_BACKEND_CREDENTIALS=/project/service_account_credentials.json \
  --volume $TF_VOLUME-tf:/terraform \
  --volume $PWD:/project msb140610/terraform-runner:1.1 $@
