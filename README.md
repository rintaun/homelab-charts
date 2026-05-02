# homelab-charts

Various Helm charts for services that I host locally.

## Usage

```bash
helm repo add homelab-charts https://rintaun.github.io/homelab-charts
helm repo update
helm search repo homelab-charts
```

## Charts

| Chart | Description |
| ----- | ----------- |
| _(none yet)_ | |

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
