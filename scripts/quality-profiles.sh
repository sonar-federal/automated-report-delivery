#!/usr/bin/env bash
# The quality profile (rule set) each language is analyzed with for a project, with the number of
# active rules, whether it is the default or inherited, and when its rules last changed.
# Usage: ./quality-profiles.sh <project-key>  ->  output/<project-key>-quality-profiles.json
: "${SONARQUBE_CLI_SERVER:?set SONARQUBE_CLI_SERVER}" "${SONARQUBE_CLI_TOKEN:?set SONARQUBE_CLI_TOKEN}" "${1:?missing argument - see usage at top of file}"
set -eo pipefail
O=$(dirname "$0")/../output; mkdir -p "$O"; T=$(mktemp); trap 'rm -f "$T"' EXIT
api() { curl -fsS --max-time 60 --retry 3 -u "$SONARQUBE_CLI_TOKEN:" -G "$SONARQUBE_CLI_SERVER$1" "${@:2}"; }
api /api/components/show --data-urlencode "component=$1" > /dev/null   # fails on an unknown project key
api /api/qualityprofiles/search --data-urlencode "project=$1" | jq . > "$T"
mv "$T" "$O/$1-quality-profiles.json"
