#!/usr/bin/env bash
# Recent analysis tasks for a project (status, duration, branch, warnings) and anything queued or
# running now. Answers "did the scan actually run, and did it finish cleanly?"
# Usage: ./compute-engine.sh <project-key>  ->  output/<project-key>-compute-engine.json
# Returns the 100 most recent tasks across all branches; each task names its branch.
: "${SONAR_CLI_SERVER:?set SONAR_CLI_SERVER}" "${SONAR_CLI_TOKEN:?set SONAR_CLI_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -eo pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"; D=$(mktemp -d); trap 'rm -rf "$D"' EXIT
api() { curl -fsS --max-time 60 --retry 3 -u "$SONAR_CLI_TOKEN:" -G "$SONAR_CLI_SERVER$1" "${@:2}"; }
api /api/components/show --data-urlencode "component=$1" > /dev/null   # fails on an unknown project key
api /api/ce/activity --data-urlencode "component=$1" -d ps=100 > "$D/activity.json"
api /api/ce/component --data-urlencode "component=$1" > "$D/now.json"
jq -n --slurpfile a "$D/activity.json" --slurpfile n "$D/now.json" '{running: $n[0].current, queued: $n[0].queue, recent: $a[0].tasks}' > "$D/out"
mv "$D/out" "$O/$1-compute-engine.json"
