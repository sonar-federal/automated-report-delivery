#!/usr/bin/env bash
# Current project metrics (the numbers behind the dashboard): size, coverage, duplication, issue counts,
# A-E ratings, technical debt, and the same on new code. Includes each metric's name and description.
# Usage: ./measures.sh <project-key> [branch]  ->  output/<project-key>-measures.json
# To change the metrics, edit M below (keys from /api/metrics/search; a metric with no value is omitted).
: "${SONAR_CLI_SERVER:?set SONAR_CLI_SERVER}" "${SONAR_CLI_TOKEN:?set SONAR_CLI_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -eo pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"; T=$(mktemp); trap 'rm -f "$T"' EXIT
api() { curl -fsS --max-time 60 --retry 3 -u "$SONAR_CLI_TOKEN:" -G "$SONAR_CLI_SERVER$1" "${@:2}"; }
M=alert_status,ncloc,coverage,line_coverage,branch_coverage,duplicated_lines_density,duplicated_blocks,bugs,vulnerabilities,code_smells,security_hotspots,violations,reliability_rating,security_rating,sqale_rating,security_review_rating,sqale_index,sqale_debt_ratio,cognitive_complexity,complexity,tests,test_failures,new_lines,new_coverage,new_duplicated_lines_density,new_bugs,new_vulnerabilities,new_code_smells,new_security_hotspots,new_violations,new_reliability_rating,new_security_rating,new_maintainability_rating,new_security_review_rating
api /api/components/show --data-urlencode "component=$1" ${2:+--data-urlencode "branch=$2"} > /dev/null   # fails on an unknown project key or branch
api /api/measures/component --data-urlencode "component=$1" --data-urlencode "metricKeys=$M" -d additionalFields=metrics ${2:+--data-urlencode "branch=$2"} | jq . > "$T"
mv "$T" "$O/$1-measures.json"
