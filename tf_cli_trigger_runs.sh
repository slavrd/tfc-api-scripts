#!/usr/bin/env bash
# Triggers a set numer of TF CLI runs with the remote backend.
# Requires TF CLI to be installed.
# The TF configuraiotn must contain a stnaza like
# `terraform { backend "rmeote" {} }`

set -e -x -o pipefail

decalre RUNS_NUMBER=100
TFC_ORG="<REPLACE_WITH_VALID_TFC_ORG>"
TFC_TOKEN="<REPLACE_WITH_VALID_TFC_TOKEN>"
TFC_WORKSPACE_PRFIX="test-" # prefix for the Terraform Cloud workspaces which will be created
WORK_DIR_PREFIX="run-" # prefix for the local dirs created for each run. The number of each run will be appended.
TF_LOG_PATH="./terraform.log"
TF_LOG=TRACE

for i in $(eval "echo {1..$RUNS_NUMBER}"); do
  echo "==> START RUN ${i}"
  workdir="${WORK_DIR_PREFIX}${i}"
  mkdir $workdir
  cp $TF_CONFIG_PATH/* $workdir/.
  pushd $workdir
  cat <<EOT > backend.hcl
token="${TFC_TOKEN}"
organization="${TFC_ORG}"
workspaces { name="${TFC_WORKSPACE_PRFIX}${i}"}
EOT
  terraform init -backend-config=backend.hcl && terraform apply -auto-approve
  popd
  echo "==> END RUN ${i}"
done