#!/usr/bin/env bash
# Executive summary PDF for a project or portfolio. Enterprise Edition and above.
# Usage: ./report-portfolio-pdf.sh <project-or-portfolio-key> [branch]  ->  output/<key>-executive.pdf
: "${SONAR_HOST_URL:?set SONAR_HOST_URL}" "${SONAR_TOKEN:?set SONAR_TOKEN}" "${1:?missing argument - see usage at top of file}"
O=$(dirname "$0")/../output; mkdir -p "$O"
curl -fsS -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/governance_reports/download?componentKey=$1${2:+&branchKey=$2}" -o "$O/$1-executive.pdf"
