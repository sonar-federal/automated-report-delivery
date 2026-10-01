#!/usr/bin/env bash
# Regulatory report bundle (zip) for compliance review. Enterprise Edition and above.
# Usage: ./report-regulatory.sh <project-key> [branch]  ->  output/<project-key>-regulatory.zip
: "${SONAR_HOST_URL:?set SONAR_HOST_URL}" "${SONAR_TOKEN:?set SONAR_TOKEN}" "${1:?missing argument - see usage at top of file}"
O=$(dirname "$0")/../output; mkdir -p "$O"
curl -fsS -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/regulatory_reports/download?project=$1${2:+&branch=$2}" -o "$O/$1-regulatory.zip"
