{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mimir.name" -}}
{{- default ( include "mimir.infixName" . ) .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mimir.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default ( include "mimir.infixName" . ) .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Calculate the infix for naming
*/}}
{{- define "mimir.infixName" -}}
{{- if and .Values.enterprise.enabled .Values.enterprise.legacyLabels -}}enterprise-metrics{{- else -}}mimir{{- end -}}
{{- end -}}


{{/*
Resource labels
Params:
  ctx = . context
  component = component name (optional)
  rolloutZoneName = rollout zone name (optional)
*/}}
{{- define "mimir.labels" -}}
application.giantswarm.io/team: {{ default "atlas" }}
{{- if .ctx.Values.enterprise.legacyLabels }}
{{- if .component -}}
app: {{ include "mimir.name" .ctx }}-{{ .component }}
{{- else -}}
app: {{ include "mimir.name" .ctx }}
{{- end }}
chart: {{ template "mimir.chart" .ctx }}
heritage: {{ .ctx.Release.Service }}
release: {{ .ctx.Release.Name }}

{{- else -}}

helm.sh/chart: {{ include "mimir.chart" .ctx }}
app.kubernetes.io/name: {{ include "mimir.name" .ctx }}
app.kubernetes.io/instance: {{ .ctx.Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- if .memberlist }}
app.kubernetes.io/part-of: memberlist
{{- end }}
{{- if .ctx.Chart.AppVersion }}
app.kubernetes.io/version: {{ .ctx.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .ctx.Release.Service }}
{{- end }}
{{- if .rolloutZoneName }}
{{-   if not .component }}
{{-     printf "Component name cannot be empty if rolloutZoneName (%s) is set" .rolloutZoneName | fail }}
{{-   end }}
name: "{{ .component }}-{{ .rolloutZoneName }}" {{- /* Currently required for rollout-operator. https://github.com/grafana/rollout-operator/issues/15 */}}
rollout-group: {{ .component }}
zone: {{ .rolloutZoneName }}
{{- end }}
{{- end -}}

{{/*
POD labels
Params:
  ctx = . context
  component = name of the component
  memberlist = true if part of memberlist gossip ring
  rolloutZoneName = rollout zone name (optional)
*/}}
{{- define "mimir.podLabels" -}}
{{- if .ctx.Values.enterprise.legacyLabels }}
{{- if .component -}}
app: {{ include "mimir.name" .ctx }}-{{ .component }}
{{- if not .rolloutZoneName }}
name: {{ .component }}
{{- end }}
{{- end }}
{{- if .memberlist }}
gossip_ring_member: "true"
{{- end -}}
{{- if .component }}
target: {{ .component }}
release: {{ .ctx.Release.Name }}
{{- end }}
{{- else -}}
helm.sh/chart: {{ include "mimir.chart" .ctx }}
app.kubernetes.io/name: {{ include "mimir.name" .ctx }}
app.kubernetes.io/instance: {{ .ctx.Release.Name }}
app.kubernetes.io/version: {{ .ctx.Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .ctx.Release.Service }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- if .memberlist }}
app.kubernetes.io/part-of: memberlist
{{- end }}
{{- end }}
{{- $componentSection := include "mimir.componentSectionFromName" . | fromYaml }}
{{- with ($componentSection).podLabels }}
{{ toYaml . }}
{{- end }}
{{- if .rolloutZoneName }}
{{-   if not .component }}
{{-     printf "Component name cannot be empty if rolloutZoneName (%s) is set" .rolloutZoneName | fail }}
{{-   end }}
name: "{{ .component }}-{{ .rolloutZoneName }}" {{- /* Currently required for rollout-operator. https://github.com/grafana/rollout-operator/issues/15 */}}
rollout-group: {{ .component }}
zone: {{ .rolloutZoneName }}
{{- end }}
{{- end -}}


{{/*
Service selector labels
Params:
  ctx = . context
  component = name of the component
  rolloutZoneName = rollout zone name (optional)
*/}}
{{- define "mimir.selectorLabels" -}}
{{- if .ctx.Values.enterprise.legacyLabels }}
{{- if .component -}}
app: {{ include "mimir.name" .ctx }}-{{ .component }}
{{- end }}
release: {{ .ctx.Release.Name }}
{{- else -}}
app.kubernetes.io/name: {{ include "mimir.name" .ctx }}
app.kubernetes.io/instance: {{ .ctx.Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- end -}}
{{- if .rolloutZoneName }}
{{-   if not .component }}
{{-     printf "Component name cannot be empty if rolloutZoneName (%s) is set" .rolloutZoneName | fail }}
{{-   end }}
rollout-group: {{ .component }}
zone: {{ .rolloutZoneName }}
{{- end }}
{{- end -}}

