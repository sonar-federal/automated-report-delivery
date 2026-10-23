#!/usr/bin/env bash
# Every branch and pull request analyzed for a project: quality gate status, last analysis date,
# and the AI Code Assurance level of each branch.
# Usage: ./branches-prs.sh <project-key>  ->  output/<project-key>-branches-prs.json
: "${SONARQUBE_CLI_SERVER:?set SONARQUBE_CLI_SERVER}" "${SONARQUBE_CLI_TOKEN:?set SONARQUBE_CLI_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -eo pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"; D=$(mktemp -d); trap 'rm -rf "$D"' EXIT
api() { curl -fsS --max-time 60 --retry 3 -u "$SONARQUBE_CLI_TOKEN:" -G "$SONARQUBE_CLI_SERVER$1" "${@:2}"; }
api /api/components/show --data-urlencode "component=$1" > /dev/null   # fails on an unknown project key
api /api/project_branches/list --data-urlencode "project=$1" | jq .branches > "$D/branches.json"
api /api/project_pull_requests/list --data-urlencode "project=$1" | jq .pullRequests > "$D/prs.json"
jq -r '.[].name' "$D/branches.json" | while IFS= read -r B; do
  api /api/project_branches/get_ai_code_assurance --data-urlencode "project=$1" --data-urlencode "branch=$B" | jq --arg b "$B" '{name: $b, aiCodeAssurance}'
done | jq -s . > "$D/ai.json"
jq -n --slurpfile b "$D/branches.json" --slurpfile a "$D/ai.json" --slurpfile p "$D/prs.json" \
  '{branches: ($b[0] | map(. + {aiCodeAssurance: (. as $x | $a[0][] | select(.name == $x.name) | .aiCodeAssurance)})), pullRequests: $p[0]}' > "$D/out"
mv "$D/out" "$O/$1-branches-prs.json"
