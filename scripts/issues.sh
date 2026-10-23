#!/usr/bin/env bash
# Issues (bugs, vulnerabilities, code smells) recorded for a project, as JSON.
# Usage: ./issues.sh <project-key> [branch]  ->  output/<project-key>-issues.json
# Pages through the results (500 per call) up to the 10,000 the API allows; for more, add filters.
: "${SONAR_CLI_SERVER:?set SONAR_CLI_SERVER}" "${SONAR_CLI_TOKEN:?set SONAR_CLI_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -eo pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"; D=$(mktemp -d); trap 'rm -rf "$D"' EXIT
api() { curl -fsS --max-time 60 --retry 3 -u "$SONAR_CLI_TOKEN:" -G "$SONAR_CLI_SERVER$1" "${@:2}"; }
api /api/components/show --data-urlencode "component=$1" ${2:+--data-urlencode "branch=$2"} > /dev/null   # fails on an unknown project key or branch
page() { api /api/issues/search --data-urlencode "componentKeys=$1" ${2:+--data-urlencode "branch=$2"} -d ps=500 -d "p=$3"; }
page "$1" "$2" 1 > "$D/1.json"
TOTAL=$(jq .paging.total "$D/1.json")
[ "$TOTAL" -le 10000 ] || echo "warning: $TOTAL issues match; the API returns only the first 10,000. Add filters." >&2
PAGES=$(( TOTAL > 10000 ? 20 : (TOTAL + 499) / 500 ))
for ((p = 2; p <= PAGES; p++)); do page "$1" "$2" "$p" > "$D/$p.json"; done
jq -s '.[0] + {issues: (map(.issues) | add), components: (map(.components) | add | unique_by(.key))} | .paging.pageIndex = 1 | .paging.pageSize = (.issues | length)' $(seq -f "$D/%g.json" 1 "$(( PAGES > 0 ? PAGES : 1 ))") > "$D/out"
mv "$D/out" "$O/$1-issues.json"
