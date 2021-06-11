#/usr/bin/env bash
# Deletes all workspaces whose names contain a provided string
set -e -x -o pipefail

# Input - set the environment variables described below
#
# export TOKEN="<VALID_TFC_TOKEN>"
# export TFC_ORG="<TFC_ORGANIZATION>"
# export DELETE_STRING="<STRING_TO_MATCH_AGAINST_WORKSPACES_NAMES>"

# Get all workspce names that contain the $DELETE_STRING value.
# TFC api reposnses are paged and so we get the workspces in batches of 100.
wsnames=$(curl -sSf \
  --header "Authorization: Bearer ${TOKEN}" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/organizations/${TFC_ORG}/workspaces?page%5Bsize%5D=100" \
  | jq -r ".data[].attributes.name | select(. | contains(\"${DELETE_STRING}\"))")

# Start deleteing the worksapces.
# Will delete all workspaces in batches of 100.
echo "==> Begin worksapce deletion in batches of 100..."
while [ "$wsnames" != "" ]; do
  echo "==> Start deletion batch..."

  for ws in $wsnames; do 
    curl \
      --header "Authorization: Bearer ${TOKEN}" \
      --header "Content-Type: application/vnd.api+json" \
      --request DELETE \
      "https://app.terraform.io/api/v2/organizations/${TFC_ORG}/workspaces/${ws}" 
  done

# Get a new batch of workspce names that contain the $DELETE_STRING value.
# Normally this should happen when there were more than 100 workspaces to begin with.
  wsnames=$(curl \
  --header "Authorization: Bearer ${TOKEN}" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/organizations/${TFC_ORG}/workspaces?page%5Bsize%5D=100" \
  | jq -r ".data[].attributes.name | select(. | contains(\"${DELETE_STRING}\"))")
  
done
echo "==> Script finished."
