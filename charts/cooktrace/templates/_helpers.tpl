{{/*
Fully-qualified container image reference.
Supports optional digest pinning: repository:tag@sha256:...
*/}}
{{- define "cooktrace.image" -}}
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
{{- define "cooktrace.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cooktrace.fullname" -}}
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
{{- define "cooktrace.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "cooktrace.labels" -}}
helm.sh/chart: {{ include "cooktrace.chart" . }}
{{ include "cooktrace.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "cooktrace.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cooktrace.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "cooktrace.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cooktrace.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret that holds JWT_SECRET and the optional credentials.
Uses secret.secretName when set, otherwise defaults to the chart fullname.
*/}}
{{- define "cooktrace.secretName" -}}
{{- default (include "cooktrace.fullname" .) .Values.secret.secretName }}
{{- end }}

{{/*
Name of the PersistentVolumeClaim for the SQLite database.
Uses persistence.db.existingClaimName when set, otherwise <fullname>-db.
*/}}
{{- define "cooktrace.dbClaimName" -}}
{{- default (printf "%s-db" (include "cooktrace.fullname" .)) .Values.persistence.db.existingClaimName }}
{{- end }}

{{/*
Name of the PersistentVolumeClaim for uploads.
Uses persistence.uploads.existingClaimName when set, otherwise <fullname>-uploads.
*/}}
{{- define "cooktrace.uploadsClaimName" -}}
{{- default (printf "%s-uploads" (include "cooktrace.fullname" .)) .Values.persistence.uploads.existingClaimName }}
{{- end }}

{{/*
Renders a tri-state boolean as "1"/"0" for env vars whose unset state means
"use the application default". Pass the value directly; null renders nothing.
*/}}
{{- define "cooktrace.flag" -}}
{{- ternary "1" "0" . -}}
{{- end }}
