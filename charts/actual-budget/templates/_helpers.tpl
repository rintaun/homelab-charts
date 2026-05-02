{{/*
Fully-qualified container image reference.
Supports optional digest pinning: repository:tag@sha256:...
*/}}
{{- define "actual-budget.image" -}}
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

{{/*
Expand the name of the chart.
*/}}
{{- define "actual-budget.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "actual-budget.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart label.
*/}}
{{- define "actual-budget.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "actual-budget.labels" -}}
helm.sh/chart: {{ include "actual-budget.chart" . }}
{{ include "actual-budget.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "actual-budget.selectorLabels" -}}
app.kubernetes.io/name: {{ include "actual-budget.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "actual-budget.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "actual-budget.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding Actual Budget credentials.
- mode=existing: uses secret.existingSecretName (required)
- mode=create or mode=external: uses the chart fullname
*/}}
{{- define "actual-budget.secretName" -}}
{{- if eq .Values.secret.mode "existing" }}
{{- required "secret.existingSecretName is required when secret.mode is \"existing\"" .Values.secret.existingSecretName }}
{{- else }}
{{- include "actual-budget.fullname" . }}
{{- end }}
{{- end }}
