#!/usr/bin/env bash
# Security report: a PDF covering all standards, plus JSON for one standard (e.g. OWASP Top 10).
# Usage: ./report-security.sh <project-key> [standard] [branch]  ->  output/<project-key>-security.pdf and -security-<standard>.json
# Standards: sonarsourceSecurity owaspTop10 cweTop25 pciDss owaspAsvs stig casa cra owaspLlmTop10
#            owaspMobileTop10 owaspMasvs-v2 (varies by version)
: "${SONARQUBE_CLI_SERVER:?set SONARQUBE_CLI_SERVER}" "${SONARQUBE_CLI_TOKEN:?set SONARQUBE_CLI_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -eo pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"; T=$(mktemp); trap 'rm -f "$T"' EXIT
api() { curl -fsS --max-time 120 --retry 3 -u "$SONARQUBE_CLI_TOKEN:" -G "$SONARQUBE_CLI_SERVER$1" "${@:2}"; }
S=${2:-owaspTop10}
api /api/components/show --data-urlencode "component=$1" ${3:+--data-urlencode "branch=$3"} > /dev/null   # fails on an unknown project key or branch
api /api/security_reports/download --data-urlencode "project=$1" ${3:+--data-urlencode "branch=$3"} -o "$T"
mv "$T" "$O/$1-security.pdf"
api /api/security_reports/show --data-urlencode "project=$1" --data-urlencode "standard=$S" -d includeDistribution=true ${3:+--data-urlencode "branch=$3"} | jq . > "$T"
mv "$T" "$O/$1-security-$S.json"
