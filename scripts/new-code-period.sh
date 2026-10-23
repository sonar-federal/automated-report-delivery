#!/usr/bin/env bash
# The new code definition: what "new code" is measured against (previous version, number of days, or
# a reference branch), for the project and any branch with its own setting. Explains quality gate results.
# Usage: ./new-code-period.sh <project-key> [branch]  ->  output/<project-key>-new-code-period.json
# The branch argument selects which branch's effective setting is reported under "effective".
: "${SONARQUBE_CLI_SERVER:?set SONARQUBE_CLI_SERVER}" "${SONARQUBE_CLI_TOKEN:?set SONARQUBE_CLI_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -eo pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"; D=$(mktemp -d); trap 'rm -rf "$D"' EXIT
api() { curl -fsS --max-time 60 --retry 3 -u "$SONARQUBE_CLI_TOKEN:" -G "$SONARQUBE_CLI_SERVER$1" "${@:2}"; }
api /api/components/show --data-urlencode "component=$1" ${2:+--data-urlencode "branch=$2"} > /dev/null   # fails on an unknown project key or branch
api /api/new_code_periods/show --data-urlencode "project=$1" ${2:+--data-urlencode "branch=$2"} > "$D/show.json"
api /api/new_code_periods/list --data-urlencode "project=$1" > "$D/list.json"
jq -n --slurpfile e "$D/show.json" --slurpfile l "$D/list.json" '{effective: $e[0], settings: $l[0].newCodePeriods}' > "$D/out"
mv "$D/out" "$O/$1-new-code-period.json"
