#/usr/bin/env bash
# Deletes all workspaces whose names contain a provided string
set -e -x -o pipefail

TOKEN="<VALID_TFC_TOKEN>"
TFC_ORG="<TFC_ORGANIZATION>"
DELETE_STRING="<STRING_TO_MATCH_AGAINST_WORKSPACES_NAMES>"

wsnames=$(curl -sSf \
  --header "Authorization: Bearer ${TOKEN}" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/organizations/${TFC_ORG}/workspaces?page%5Bsize%5D=100" \
  | jq -r ".data[].attributes.name | select(. | contains(\"${DELETE_STRING}\"))")

while [ "$wsnames" != "" ]; do
  echo "==> Start delete iteration."

  for ws in $wsnames; do 
    curl \
      --header "Authorization: Bearer ${TOKEN}" \
      --header "Content-Type: application/vnd.api+json" \
      --request DELETE \
      "https://app.terraform.io/api/v2/organizations/${TFC_ORG}/workspaces/${ws}" 
  done

  wsnames=$(curl \
  --header "Authorization: Bearer ${TOKEN}" \
  --header "Content-Type: application/vnd.api+json" \
  "https://app.terraform.io/api/v2/organizations/${TFC_ORG}/workspaces?page%5Bsize%5D=100" \
  | jq -r ".data[].attributes.name | select(. | contains(\"${DELETE_STRING}\"))")
  
done
echo "==> Script finished."