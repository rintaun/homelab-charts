# Contributing

This document describes the conventions used when authoring Helm charts in this repository.

---

## Chart layout

```
my-chart/
  Chart.yaml
  values.yaml
  templates/
    _helpers.tpl
    deployment.yaml   # one resource kind per file
    service.yaml
    ingress.yaml
    pvc.yaml
    secret.yaml
    rbac.yaml         # if the chart needs RBAC
    crd.yaml          # if the chart owns a CRD
```

- Template file names use **dashed lowercase** and match the primary resource kind they contain.
- Multiple related resources of the same kind in one file are acceptable (e.g. `rbac.yaml`
  with Role + RoleBinding).
- Helper partials go in `_helpers.tpl`.

---

## Chart.yaml

```yaml
apiVersion: v2
name: my-chart          # lowercase, words separated by dashes
type: application
version: 0.1.0          # SemVer; bump on every change
appVersion: "1.2.3"     # upstream application version; defaults image tag when image.tag=""
description: >
  Short description of the application.
home: https://upstream-project.example.com
sources:
  - https://github.com/upstream/project
keywords:
  - relevant
  - tags
dependencies: []
```

- `name` must be lowercase letters, numbers, and dashes — no underscores.
- `appVersion` is the default image tag. Always prefer a pinned upstream version over `latest`.

---

## values.yaml

### Naming

- Keys start with a **lowercase letter**, words in **camelCase**.
- No hyphens in key names (`routerIp`, not `router-ip`).
- Every key must have an inline comment beginning with the key name:

  ```yaml
  # replicaCount is the number of pod replicas to run.
  replicaCount: 1
  ```

### Standard top-level keys (always present)

```yaml
nameOverride: ""
fullnameOverride: ""

replicaCount: 1

image:
  repository: ghcr.io/example/my-app
  # tag overrides the chart appVersion when set.
  tag: ""
  # digest pins to an immutable image reference. Prepend sha256: or omit the prefix.
  digest: ""
  pullPolicy: IfNotPresent

serviceAccount:
  # create specifies whether a ServiceAccount should be created.
  create: true
  annotations: {}
  # name overrides the generated name when set.
  name: ""

podAnnotations: {}

podSecurityContext:
  runAsNonRoot: true
  runAsUser: <uid>
  seccompProfile:
    type: RuntimeDefault

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop: ["ALL"]

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    memory: 256Mi   # no cpu limit — avoid throttling
```

CPU limits are deliberately omitted. CPU requests are always set.

### Application configuration (`config`)

Application settings that map to environment variables must be represented as named values
under the top-level `config` key, not left as raw entries in a freeform `env` map. This keeps
the public interface of the chart explicit, documented, and overridable with `--set`.

```yaml
# Good — named, commented, conditionally rendered
config:
  # loginMethod sets ACTUAL_LOGIN_METHOD. Leave empty to use the application's default.
  loginMethod: ""

# Bad — opaque, no documentation, easy to get the key wrong
env:
  ACTUAL_LOGIN_METHOD: header
```

The `env` map is reserved for truly generic pass-through variables (e.g. `TZ`) that have no
chart-specific meaning. All settings the chart is designed to configure must have their own
named key under `config`.

In templates, render first-class values conditionally with `{{- with }}` so that an empty
default produces no environment variable at all, preserving the application's own default
behaviour:

```gotpl
{{- with .Values.config.loginMethod }}
- name: ACTUAL_LOGIN_METHOD
  value: {{ . | quote }}
{{- end }}
```

### Prefer flat values over deeply nested maps

Use nesting only when several related keys form a logical group (e.g. `image`, `serviceAccount`).
Flat values are easier to override with `--set`.

### Make types explicit for strings

Quote values that must remain strings to survive YAML type coercion:

```yaml
config:
  routerIp: "10.13.1.100"   # quoted to prevent YAML parsing it as something else
  debug: false               # booleans stay unquoted
```

---

## _helpers.tpl

Every chart must define the following named templates, prefixed by the chart name:

| Template | Purpose |
|---|---|
| `<chart>.name` | `default .Chart.Name .Values.nameOverride \| trunc 63 \| trimSuffix "-"` |
| `<chart>.fullname` | Release-qualified name with 63-char truncation |
| `<chart>.chart` | `Chart.Name-Chart.Version` for `helm.sh/chart` label |
| `<chart>.labels` | Full label set (see Labels section) |
| `<chart>.selectorLabels` | Stable subset used in `selector.matchLabels` |
| `<chart>.serviceAccountName` | Resolves to generated or overridden SA name |
| `<chart>.image` | Builds `repository:tag[@digest]` reference (see below) |

The `<chart>.image` helper must handle optional digest pinning:

```gotpl
{{- define "my-chart.image" -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag -}}
{{- if .Values.image.digest -}}
{{- $digest := .Values.image.digest -}}
{{- if not (hasPrefix "sha256:" $digest) -}}
{{- $digest = printf "sha256:%s" $digest -}}
{{- end -}}
{{- printf "%s:%s@%s" .Values.image.repository $tag $digest -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end -}}
{{- end }}
```

Use `{{ include "my-chart.image" . | quote }}` in deployment templates.

---

## Labels

Apply `labels` on all resource `metadata` and `selectorLabels` on PodTemplate `metadata.labels`
and Deployment/Service `selector.matchLabels`. Never include mutable values
(e.g. version, date) in selector labels — selectors are immutable after creation.

Standard label set emitted by `<chart>.labels`:

```yaml
helm.sh/chart: my-chart-0.1.0
app.kubernetes.io/name: my-chart
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
```

Standard selector label set emitted by `<chart>.selectorLabels`:

```yaml
app.kubernetes.io/name: my-chart
app.kubernetes.io/instance: "{{ .Release.Name }}"
```

---

## Secrets

Charts that need a secret credential use a simple two-field pattern:

```yaml
secret:
  # create controls whether the chart creates the Secret.
  # Defaults to false — provide a pre-existing Secret via secretName instead.
  # Setting create=true is supported but discouraged for production use, as it
  # requires putting secret values in values.yaml or passing them via --set.
  create: false
  # secretName is the name of the Secret to use.
  # When create=false, this must name a pre-existing Secret.
  # Defaults to the chart fullname when empty.
  secretName: ""
  # <key>: ""  # plaintext values used when create=true
```

When `create=true`, use `required` to fail fast on empty values:

```gotpl
stringData:
  api-key: {{ required "secret.apiKey is required when secret.create is true" .Values.secret.apiKey | quote }}
```

ExternalSecrets (or any other external secret management) are intentionally out of scope for
these charts. Consumers should create Secrets (or have their secret operator create them) before
installing the chart, then reference the pre-existing Secret via `secret.secretName`.

---

## Security defaults

Every chart ships with security hardening on by default. Relax only when the upstream image
genuinely requires it (document why with a comment).

- `podSecurityContext.runAsNonRoot: true`
- `podSecurityContext.seccompProfile.type: RuntimeDefault`
- `securityContext.allowPrivilegeEscalation: false`
- `securityContext.readOnlyRootFilesystem: true` (set `false` if the app writes outside mounted volumes)
- `securityContext.capabilities.drop: ["ALL"]`

---

## RBAC

Gate all RBAC resources on a `rbac.create` flag:

```yaml
rbac:
  create: true
```

Keep ClusterRoles minimal — grant only the verbs and resources the controller actually uses.
Prefer namespace-scoped Roles unless the workload genuinely needs cluster-wide access.

---

## Ingress

All ingress configuration lives under the `ingress` key. The chart must gate ingress creation on
`ingress.host` being non-empty — do not render an Ingress when no host is set.

```yaml
ingress:
  # host is the DNS hostname to expose the service on. Leave empty to skip ingress creation.
  host: ""
  # className is the IngressClass to use. Empty string uses the cluster's default IngressClass.
  className: ""
  # annotations are added to the Ingress resource metadata.
  annotations: {}
```

Render `ingressClassName` and `annotations` conditionally:

```gotpl
{{- if .Values.ingress.host }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
...
spec:
  {{- with .Values.ingress.className }}
  ingressClassName: {{ . }}
  {{- end }}
  ...
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
```

TLS `secretName` is set to the hostname value so cert-manager (or manual TLS) stores the
certificate under a predictable name.

---

## Persistence

Charts that need persistent storage expose PVC configuration under `persistence.<name>`.

For simple cases (single writable volume), use:

```yaml
persistence:
  data:
    # storageClass is the StorageClass to use. Empty string uses the cluster default.
    storageClass: ""
    # size is the requested storage capacity.
    size: 1Gi
```

For volumes that may be large, pre-existing, or backed by external storage (e.g. a shared media
library), expose the full claim/volume pattern:

```yaml
persistence:
  media:
    # existingClaimName uses a pre-existing PVC instead of creating one.
    # When set, claim and volume below are ignored entirely.
    existingClaimName: ""

    # claim configures the PVC created by this chart.
    # Ignored when existingClaimName is set.
    claim:
      # storageClassName is the StorageClass to use. Empty string uses the cluster default.
      storageClassName: ""
      # accessModes are the PVC access modes.
      accessModes:
        - ReadWriteOnce
      # size is the requested storage capacity.
      size: 10Gi
      # volumeName explicitly binds the PVC to a specific PV.
      # Automatically set when volume.nfs.server is configured. Leave empty for dynamic provisioning.
      volumeName: ""

    # volume creates a static PersistentVolume bound to the chart's PVC.
    # Set volume.nfs.server to enable PV creation; leave empty to skip.
    volume:
      nfs:
        # server is the NFS server hostname or IP. Leave empty to skip PV creation.
        server: ""
        # path is the exported NFS path.
        path: ""
        mountOptions:
          - hard
          - nfsvers=4
```

This gives consumers three options without requiring manual resource creation outside the chart:

1. **Dynamic provisioning** — leave `existingClaimName` empty and set `claim.storageClassName`.
2. **NFS static PV** — set `volume.nfs.server` and `volume.nfs.path`; the chart creates both the
   PV and PVC.
3. **Pre-existing PVC** — set `existingClaimName`; the chart skips PV/PVC creation entirely.

---

## CRDs

If a chart owns a CRD, embed it in `templates/crd.yaml`. This lets GitOps tools install the CRD
in the same sync as the controller that uses it. The drawback is that `helm uninstall` will delete
the CRD; document this in the chart README.

---

## Namespaces

Do not hardcode `metadata.namespace` in templates. The namespace is supplied by the deployer
(`helm install --namespace` or a GitOps tool's Application spec).

---

## Deployment strategy

- Use `strategy.type: Recreate` for workloads with a single writable PVC (SQLite, local
  file storage) to avoid two pods mounting the same volume simultaneously.
- Use the default `RollingUpdate` for stateless workloads.

---

## Formatting

- YAML indentation: **2 spaces**, never tabs.
- Template directives: space after `{{` and before `}}`: `{{ .Values.foo }}`.
- Use `{{-` / `-}}` to strip whitespace where it would produce blank lines in the output.
- Use `{{- toYaml .Values.foo | nindent N }}` for block scalars.
- Use `| quote` when interpolating string values into YAML scalar positions to prevent
  type coercion surprises.
