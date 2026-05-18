{{/*
Expand the name of the chart.
*/}}
{{- define "immich.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "immich.fullname" -}}
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
{{- define "immich.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to all resources.
*/}}
{{- define "immich.labels" -}}
helm.sh/chart: {{ include "immich.chart" . }}
app.kubernetes.io/name: {{ include "immich.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels — stable subset used in matchLabels.
*/}}
{{- define "immich.selectorLabels" -}}
app.kubernetes.io/name: {{ include "immich.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component-specific selector labels.
Usage: include "immich.componentSelectorLabels" (list . "server")
*/}}
{{- define "immich.componentSelectorLabels" -}}
{{- $root := index . 0 }}
{{- $component := index . 1 }}
app.kubernetes.io/name: {{ include "immich.name" $root }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
app.kubernetes.io/component: {{ $component }}
{{- end }}

{{/*
Name of the CNPG cluster.
*/}}
{{- define "immich.dbClusterName" -}}
{{- printf "%s-db" (include "immich.fullname" .) }}
{{- end }}

{{/*
Name of the CNPG app secret created by CNPG operator for the app user.
Convention: <cluster-name>-app
*/}}
{{- define "immich.dbSecretName" -}}
{{- printf "%s-app" (include "immich.dbClusterName" .) }}
{{- end }}

{{/*
Name of the Valkey service.
*/}}
{{- define "immich.valkeyServiceName" -}}
{{- printf "%s-valkey" (include "immich.fullname" .) }}
{{- end }}

{{/*
Name of the Immich server service.
*/}}
{{- define "immich.serverServiceName" -}}
{{- printf "%s-server" (include "immich.fullname" .) }}
{{- end }}

{{/*
Name of the machine-learning service.
*/}}
{{- define "immich.mlServiceName" -}}
{{- printf "%s-machine-learning" (include "immich.fullname" .) }}
{{- end }}

{{/*
Name of the library PVC.
*/}}
{{- define "immich.libraryPVCName" -}}
{{- if .Values.persistence.library.existingClaim }}
{{- .Values.persistence.library.existingClaim }}
{{- else }}
{{- printf "%s-library" (include "immich.fullname" .) }}
{{- end }}
{{- end }}
