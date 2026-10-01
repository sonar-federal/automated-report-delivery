#!/usr/bin/env bash
# Security report: a PDF covering all standards, plus JSON for one standard (e.g. OWASP Top 10).
# Usage: ./report-security.sh <project-key> [standard] [branch]  ->  output/<project-key>-security.pdf and -security-<standard>.json
# Standards: sonarsourceSecurity owaspTop10 cweTop25 pciDss owaspAsvs stig casa cra owaspLlmTop10
#            owaspMobileTop10 owaspMasvs-v2 (varies by version)
: "${SONAR_HOST_URL:?set SONAR_HOST_URL}" "${SONAR_TOKEN:?set SONAR_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -o pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"
S=${2:-owaspTop10}
curl -fsS -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/security_reports/download?project=$1${3:+&branch=$3}" -o "$O/$1-security.pdf"
curl -fsS -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/security_reports/show?project=$1&standard=$S&includeDistribution=true${3:+&branch=$3}" | jq . > "$O/$1-security-$S.json"
