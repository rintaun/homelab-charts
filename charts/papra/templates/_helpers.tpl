{{/*
Fully-qualified container image reference.
Supports optional digest pinning: repository:tag@sha256:...
*/}}
{{- define "papra.image" -}}
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
{{- define "papra.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "papra.fullname" -}}
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
{{- define "papra.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "papra.labels" -}}
helm.sh/chart: {{ include "papra.chart" . }}
{{ include "papra.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "papra.selectorLabels" -}}
app.kubernetes.io/name: {{ include "papra.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "papra.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "papra.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret that holds AUTH_SECRET.
- mode=existing: uses secret.existingSecretName (required)
- mode=create or mode=external: uses the chart fullname
*/}}
{{- define "papra.secretName" -}}
{{- if eq .Values.secret.mode "existing" }}
{{- required "secret.existingSecretName is required when secret.mode is \"existing\"" .Values.secret.existingSecretName }}
{{- else }}
{{- include "papra.fullname" . }}
{{- end }}
{{- end }}

{{/*
Name of the Secret that holds S3 credentials.
- mode=existing: uses s3Secret.existingSecretName (required)
- mode=create or mode=external: uses the chart fullname suffixed with "-s3"
*/}}
{{- define "papra.s3SecretName" -}}
{{- if eq .Values.s3Secret.mode "existing" }}
{{- required "s3Secret.existingSecretName is required when s3Secret.mode is \"existing\"" .Values.s3Secret.existingSecretName }}
{{- else }}
{{- printf "%s-s3" (include "papra.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Name of the Secret that holds custom OAuth provider client secrets.
- mode=existing: uses oidcSecret.existingSecretName (required)
- mode=create or mode=external: uses the chart fullname suffixed with "-oidc"
*/}}
{{- define "papra.oidcSecretName" -}}
{{- if eq .Values.oidcSecret.mode "existing" }}
{{- required "oidcSecret.existingSecretName is required when oidcSecret.mode is \"existing\"" .Values.oidcSecret.existingSecretName }}
{{- else }}
{{- printf "%s-oidc" (include "papra.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Renders the AUTH_PROVIDERS_CUSTOMS JSON array string.
Field names match Papra's valibot schema (providerId, providerName, discoveryUrl).
Client secrets are referenced via Kubernetes env var interpolation: $(OIDC_<ID_UPPER>_CLIENT_SECRET).
The OIDC_*_CLIENT_SECRET env vars must be defined before this one in the container env list.
*/}}
{{- define "papra.customOAuthProvidersJson" -}}
{{- $providers := list -}}
{{- range .Values.config.auth.customOAuthProviders -}}
{{- $envVar := printf "$(OIDC_%s_CLIENT_SECRET)" (.id | upper | replace "-" "_") -}}
{{- $provider := dict "providerId" .id "providerName" .name "clientId" .clientId "clientSecret" $envVar "discoveryUrl" .discoveryUrl "scopes" (default (list "openid" "profile" "email") .scopes) -}}
{{- $providers = append $providers $provider -}}
{{- end -}}
{{- $providers | toJson -}}
{{- end }}

{{/*
Name of the Secret that holds webhook bridge credentials (forwardemail-webhook-key, webhook-secret).
- mode=existing: uses webhookBridge.secret.existingSecretName (required)
- mode=create or mode=external: uses the chart fullname suffixed with "-webhook-bridge"
*/}}
{{- define "papra.webhookBridgeSecretName" -}}
{{- if eq .Values.webhookBridge.secret.mode "existing" }}
{{- required "webhookBridge.secret.existingSecretName is required when webhookBridge.secret.mode is \"existing\"" .Values.webhookBridge.secret.existingSecretName }}
{{- else }}
{{- printf "%s-webhook-bridge" (include "papra.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Name of the PersistentVolumeClaim used for the ingestion folder.
- If ingestionFolder.existingClaimName is set, uses that.
- Otherwise uses the chart fullname suffixed with "-ingestion".
*/}}
{{- define "papra.ingestionFolderClaimName" -}}
{{- if .Values.ingestionFolder.existingClaimName }}
{{- .Values.ingestionFolder.existingClaimName }}
{{- else }}
{{- printf "%s-ingestion" (include "papra.fullname" .) }}
{{- end }}
{{- end }}
