#!/usr/bin/env bash
# History of a project's analyses (date, version, events), as JSON.
# Usage: ./analyses.sh <project-key> [branch]  ->  output/<project-key>-analyses.json
: "${SONAR_HOST_URL:?set SONAR_HOST_URL}" "${SONAR_TOKEN:?set SONAR_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -o pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"
curl -fsS -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/project_analyses/search?project=$1&ps=500${2:+&branch=$2}" | jq . > "$O/$1-analyses.json"
