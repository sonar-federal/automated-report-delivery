#!/usr/bin/env bash
# Issues (bugs, vulnerabilities, code smells) recorded for a project, as JSON.
# Usage: ./issues.sh <project-key> [branch]  ->  output/<project-key>-issues.json
# Returns up to 500 issues; for more, add filters or page with &p=2, &p=3 (max 10,000 per search).
: "${SONAR_HOST_URL:?set SONAR_HOST_URL}" "${SONAR_TOKEN:?set SONAR_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -o pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"
curl -fsS -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/issues/search?componentKeys=$1&ps=500${2:+&branch=$2}" | jq . > "$O/$1-issues.json"