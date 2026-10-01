# automated-report-delivery

Pull SonarQube scan reports through the Web API, one small script per report type. Each script
is a few lines of `curl` you can read, copy, or run on its own. Enterprise Edition and above
(the SBOM and risk report need Advanced Security).

## Setup

```bash
export SONAR_HOST_URL=https://sonarqube.example.com
export SONAR_TOKEN=...      # a User token that can see the projects (not a project analysis token)
```

Reports are written to `output/`. Needs `bash`, `curl` and `jq`. Some reports (regulatory, SBOM) may require
additional permissions on the token's user.

## Run

```bash
./scripts/issues.sh my-project            # -> output/my-project-issues.json
./scripts/issues.sh my-project release-1  # same, for a branch
```

Every script takes `<project-key>` and an optional `[branch]` (the main branch if omitted). Two take an
extra optional argument before the branch: `report-security.sh` (standard) and `report-sca-sbom.sh`
(SBOM format). Each script's first lines describe what it pulls and how to call it.

## Reports

| Script | Output | Endpoint |
|---|---|---|
| `issues.sh` | issues (JSON) | `/api/issues/search` |
| `quality-gate.sh` | quality gate status and conditions | `/api/qualitygates/project_status` |
| `analyses.sh` | analysis history | `/api/project_analyses/search` |
| `report-security.sh` | security report PDF, plus JSON for one standard | `/api/security_reports/download`, `/show` |
| `report-regulatory.sh` | regulatory report (zip) | `/api/regulatory_reports/download` |
| `report-portfolio-pdf.sh` | executive PDF, project or portfolio | `/api/governance_reports/download` |
| `report-sca-sbom.sh` | SBOM (CycloneDX or SPDX) and risk report (CSV) | `/api/v2/sca/*` |

## Automated delivery

- **Push:** create a webhook (project or global settings, or `/api/webhooks/create`). SonarQube POSTs the
  quality gate result to your URL when each analysis finishes; your receiver runs the scripts above and
  delivers the files.
- **Scheduled:** run the scripts above from cron or a pipeline.
- **Built in:** executive PDFs can be emailed on a schedule by SonarQube itself
  (`/api/governance_reports/subscribe`, `update_frequency`, `update_recipients`).

## Limits

Issue searches return at most 500 results per call and 10,000 in total; `issues.sh` notes how
to filter or page. An unknown project key or branch returns an empty result rather than an error.
