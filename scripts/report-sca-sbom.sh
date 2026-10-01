#!/usr/bin/env bash
# Software Bill of Materials (dependency inventory) and the dependency risk report (CSV).
# Usage: ./report-sca-sbom.sh <project-key> [cyclonedx|spdx_23|spdx_30] [branch]  ->  output/<project-key>-sbom.json and -risk.csv
# Requires Advanced Security.
: "${SONAR_HOST_URL:?set SONAR_HOST_URL}" "${SONAR_TOKEN:?set SONAR_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -o pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"
T=${2:-cyclonedx}
case $T in cyclonedx) A=application/vnd.cyclonedx+json;; *) A=application/spdx+json;; esac
curl -fsS -u "$SONAR_TOKEN:" -H "Accept: $A" "$SONAR_HOST_URL/api/v2/sca/sbom-reports?component=$1&type=$T${3:+&branch=$3}" | jq . > "$O/$1-sbom.json"
curl -fsS -u "$SONAR_TOKEN:" -H "Accept: text/csv" "$SONAR_HOST_URL/api/v2/sca/risk-reports?component=$1${3:+&branch=$3}" > "$O/$1-risk.csv"
