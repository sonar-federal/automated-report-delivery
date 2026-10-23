#!/usr/bin/env bash
# Software Bill of Materials (dependency inventory) and the dependency risk report (CSV).
# Usage: ./report-sca-sbom.sh <project-key> [cyclonedx|spdx_23|spdx_30] [branch]  ->  output/<project-key>-sbom.json and -risk.csv
# Requires Advanced Security.
: "${SONARQUBE_CLI_SERVER:?set SONARQUBE_CLI_SERVER}" "${SONARQUBE_CLI_TOKEN:?set SONARQUBE_CLI_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -eo pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"; T=$(mktemp); trap 'rm -f "$T"' EXIT
api() { curl -fsS --max-time 120 --retry 3 -u "$SONARQUBE_CLI_TOKEN:" -G "$SONARQUBE_CLI_SERVER$1" "${@:2}"; }
F=${2:-cyclonedx}
case $F in cyclonedx) A=application/vnd.cyclonedx+json;; *) A=application/spdx+json;; esac
api /api/components/show --data-urlencode "component=$1" ${3:+--data-urlencode "branch=$3"} > /dev/null   # fails on an unknown project key or branch
api /api/v2/sca/sbom-reports -H "Accept: $A" --data-urlencode "component=$1" --data-urlencode "type=$F" ${3:+--data-urlencode "branch=$3"} | jq . > "$T"
mv "$T" "$O/$1-sbom.json"
api /api/v2/sca/risk-reports -H "Accept: text/csv" --data-urlencode "component=$1" ${3:+--data-urlencode "branch=$3"} > "$T"
mv "$T" "$O/$1-risk.csv"
