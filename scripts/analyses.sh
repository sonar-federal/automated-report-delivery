#!/usr/bin/env bash
# History of a project's analyses (date, version, events), as JSON.
# Usage: ./analyses.sh <project-key> [branch]  ->  output/<project-key>-analyses.json
# Pages through the results (500 per call) until every analysis is returned.
: "${SONAR_CLI_SERVER:?set SONAR_CLI_SERVER}" "${SONAR_CLI_TOKEN:?set SONAR_CLI_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -eo pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"; D=$(mktemp -d); trap 'rm -rf "$D"' EXIT
api() { curl -fsS --max-time 60 --retry 3 -u "$SONAR_CLI_TOKEN:" -G "$SONAR_CLI_SERVER$1" "${@:2}"; }
api /api/components/show --data-urlencode "component=$1" ${2:+--data-urlencode "branch=$2"} > /dev/null   # fails on an unknown project key or branch
page() { api /api/project_analyses/search --data-urlencode "project=$1" ${2:+--data-urlencode "branch=$2"} -d ps=500 -d "p=$3"; }
page "$1" "$2" 1 > "$D/1.json"
PAGES=$(jq '[((.paging.total + 499) / 500 | floor), 1] | max' "$D/1.json")
for ((p = 2; p <= PAGES; p++)); do page "$1" "$2" "$p" > "$D/$p.json"; done
jq -s '.[0] + {analyses: (map(.analyses) | add)} | .paging.pageIndex = 1 | .paging.pageSize = (.analyses | length)' $(seq -f "$D/%g.json" 1 "$PAGES") > "$D/out"
mv "$D/out" "$O/$1-analyses.json"
