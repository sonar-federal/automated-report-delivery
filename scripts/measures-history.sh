#!/usr/bin/env bash
# Trend of key metrics across every analysis (one value per analysis date), as JSON, for charting.
# Usage: ./measures-history.sh <project-key> [branch]  ->  output/<project-key>-measures-history.json
# To change the metrics, edit M below. Returns up to 1,000 analyses per call.
: "${SONAR_CLI_SERVER:?set SONAR_CLI_SERVER}" "${SONAR_CLI_TOKEN:?set SONAR_CLI_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -eo pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"; T=$(mktemp); trap 'rm -f "$T"' EXIT
api() { curl -fsS --max-time 60 --retry 3 -u "$SONAR_CLI_TOKEN:" -G "$SONAR_CLI_SERVER$1" "${@:2}"; }
M=ncloc,coverage,duplicated_lines_density,bugs,vulnerabilities,code_smells,security_hotspots,sqale_index,reliability_rating,security_rating,sqale_rating
api /api/components/show --data-urlencode "component=$1" ${2:+--data-urlencode "branch=$2"} > /dev/null   # fails on an unknown project key or branch
api /api/measures/search_history --data-urlencode "component=$1" --data-urlencode "metrics=$M" -d ps=1000 ${2:+--data-urlencode "branch=$2"} | jq . > "$T"
mv "$T" "$O/$1-measures-history.json"
