#!/usr/bin/env bash
# Executive summary PDF for a project or portfolio. Enterprise Edition and above.
# Usage: ./report-portfolio-pdf.sh <project-or-portfolio-key> [branch]  ->  output/<key>-executive.pdf
: "${SONAR_CLI_SERVER:?set SONAR_CLI_SERVER}" "${SONAR_CLI_TOKEN:?set SONAR_CLI_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -eo pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"; T=$(mktemp); trap 'rm -f "$T"' EXIT
api() { curl -fsS --max-time 120 --retry 3 -u "$SONAR_CLI_TOKEN:" -G "$SONAR_CLI_SERVER$1" "${@:2}"; }
api /api/governance_reports/download --data-urlencode "componentKey=$1" ${2:+--data-urlencode "branchKey=$2"} -o "$T"
mv "$T" "$O/$1-executive.pdf"
