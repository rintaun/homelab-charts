{{/*
Fully-qualified container image reference.
Supports optional digest pinning: repository:tag@sha256:...
*/}}
{{- define "shelfarr.image" -}}
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
{{- define "shelfarr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "shelfarr.fullname" -}}
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
{{- define "shelfarr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "shelfarr.labels" -}}
helm.sh/chart: {{ include "shelfarr.chart" . }}
{{ include "shelfarr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "shelfarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "shelfarr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "shelfarr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "shelfarr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret that holds the Rails master key.
- mode=existing: uses secret.existingSecretName (required)
- mode=create or mode=external: uses the chart fullname
*/}}
{{- define "shelfarr.secretName" -}}
{{- if eq .Values.secret.mode "existing" }}
{{- required "secret.existingSecretName is required when secret.mode is \"existing\"" .Values.secret.existingSecretName }}
{{- else }}
{{- include "shelfarr.fullname" . }}
{{- end }}
{{- end }}

{{/*
Name of the PVC used for data.
*/}}
{{- define "shelfarr.dataClaimName" -}}
{{- default (printf "%s-data" (include "shelfarr.fullname" .)) .Values.persistence.data.existingClaimName }}
{{- end }}

{{/*
Name of the PVC used for audiobooks.
*/}}
{{- define "shelfarr.audiobooksClaimName" -}}
{{- default (printf "%s-audiobooks" (include "shelfarr.fullname" .)) .Values.persistence.audiobooks.existingClaimName }}
{{- end }}

{{/*
Name of the PVC used for ebooks.
*/}}
{{- define "shelfarr.ebooksClaimName" -}}
{{- default (printf "%s-ebooks" (include "shelfarr.fullname" .)) .Values.persistence.ebooks.existingClaimName }}
{{- end }}

{{/*
Name of the PVC used for downloads.
*/}}
{{- define "shelfarr.downloadsClaimName" -}}
{{- default (printf "%s-downloads" (include "shelfarr.fullname" .)) .Values.persistence.downloads.existingClaimName }}
{{- end }}
