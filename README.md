# homelab-charts

Various Helm charts for services that I host locally.

## Usage

```bash
helm repo add homelab-charts https://rintaun.github.io/homelab-charts
helm repo update
helm search repo homelab-charts
```

## Charts

| Chart | Latest | Description |
| ----- | ------ | ----------- |
| [actual-budget](charts/actual-budget) | 0.1.1 | Helm chart for Actual Budget — a local-first personal finance tool with optional OpenID Connect authentication. |
| [beets](charts/beets) | 0.2.6 | Helm chart for beets — the music geek's media organizer. Runs as a Kubernetes CronJob to periodically import and tag new music files. |
| [beets-flask](charts/beets-flask) | 0.1.1 | Helm chart for beets-flask — a web UI for the beets music organizer. Provides a browser-based interface for importing, tagging, and browsing your music library. |
| [navidrome](charts/navidrome) | 0.1.3 | Helm chart for Navidrome — a self-hosted music server and streamer compatible with the Subsonic/Airsonic API. |
| [papra](charts/papra) | 0.2.1 | Helm chart for Papra — a document management system with ingestion folder watching and optional S3 document storage. |

## Development

Charts live in the `charts/` directory. Each chart follows the standard Helm chart layout.

### Linting

```bash
helm lint charts/<chart-name>
```

### Testing

This repository uses [chart-testing](https://github.com/helm/chart-testing) (`ct`) for linting and testing charts. Pull requests that modify charts are automatically linted and tested via GitHub Actions.

### Releasing

Charts are automatically packaged and released to GitHub Pages when changes are merged to `main`, using [chart-releaser](https://github.com/helm/chart-releaser-action).
