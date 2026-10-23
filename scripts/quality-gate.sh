#!/usr/bin/env bash
# Quality gate result (pass/fail) and the status of each gate condition, as JSON.
# Usage: ./quality-gate.sh <project-key> [branch]  ->  output/<project-key>-quality-gate.json
: "${SONAR_CLI_SERVER:?set SONAR_CLI_SERVER}" "${SONAR_CLI_TOKEN:?set SONAR_CLI_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -eo pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"; T=$(mktemp); trap 'rm -f "$T"' EXIT
api() { curl -fsS --max-time 60 --retry 3 -u "$SONAR_CLI_TOKEN:" -G "$SONAR_CLI_SERVER$1" "${@:2}"; }
api /api/components/show --data-urlencode "component=$1" ${2:+--data-urlencode "branch=$2"} > /dev/null   # fails on an unknown project key or branch
api /api/qualitygates/project_status --data-urlencode "projectKey=$1" ${2:+--data-urlencode "branch=$2"} | jq . > "$T"
mv "$T" "$O/$1-quality-gate.json"
