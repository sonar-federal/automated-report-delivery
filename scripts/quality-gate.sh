#!/usr/bin/env bash
# Quality gate result (pass/fail) and the status of each gate condition, as JSON.
# Usage: ./quality-gate.sh <project-key> [branch]  ->  output/<project-key>-quality-gate.json
: "${SONAR_HOST_URL:?set SONAR_HOST_URL}" "${SONAR_TOKEN:?set SONAR_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -o pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"
curl -fsS -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/qualitygates/project_status?projectKey=$1${2:+&branch=$2}" | jq . > "$O/$1-quality-gate.json"
