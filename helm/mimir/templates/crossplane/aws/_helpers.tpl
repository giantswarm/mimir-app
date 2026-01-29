{{/*
Crossplane enabled check
*/}}
{{- define "mimir.crossplane.enabled" -}}
{{- if and .Values.crossplane.enabled .Values.crossplane.clusterName -}}
true
{{- end -}}
{{- end -}}

{{/*
Crossplane is AWS
*/}}
{{- define "mimir.crossplane.isAWS" -}}
{{- if eq .Values.crossplane.provider "aws" -}}
true
{{- end -}}
{{- end -}}

{{/*
Check if Crossplane AWS is enabled
*/}}
{{- define "mimir.crossplane.aws.enabled" -}}
{{- if and .Values.mimir.enabled .Values.crossplane.enabled (include "mimir.crossplane.isAWS" .) .Values.crossplane.aws.enabled -}}
true
{{- end -}}
{{- end -}}

{{/*
Get AWS Account ID from AWSCluster identity
Supports both AWSClusterRoleIdentity and AWSClusterControllerIdentity
*/}}
{{- define "mimir.crossplane.aws.accountId" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
{{- $accountId := "" -}}
{{- $awsCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSCluster" $clusterNamespace $clusterName -}}
{{- if $awsCluster -}}
  {{- if $awsCluster.spec.identityRef -}}
    {{- $identityName := $awsCluster.spec.identityRef.name -}}
    {{- $identityKind := $awsCluster.spec.identityRef.kind | default "AWSClusterControllerIdentity" -}}
    {{- if eq $identityKind "AWSClusterRoleIdentity" -}}
      {{- $identity := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSClusterRoleIdentity" "" $identityName -}}
      {{- if $identity -}}
        {{- /* Extract account ID from roleARN like arn:aws:iam::758407694730:role/... */ -}}
        {{- $roleARN := $identity.spec.roleARN -}}
        {{- $parts := regexSplit "::" $roleARN -1 -}}
        {{- if gt (len $parts) 1 -}}
          {{- $accountId = index (regexSplit ":" (index $parts 1) -1) 0 -}}
        {{- end -}}
      {{- end -}}
    {{- else -}}
      {{- $identity := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSClusterControllerIdentity" "" $identityName -}}
      {{- if $identity -}}
        {{- $accountId = $identity.spec.awsAccountID -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $accountId -}}
{{- end -}}

{{/*
Get OIDC Provider URL from cluster
First tries annotation aws.giantswarm.io/irsa-trust-domains, then falls back to identity
*/}}
{{- define "mimir.crossplane.aws.oidcProvider" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
{{- $oidcProvider := "" -}}
{{- $awsCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSCluster" $clusterNamespace $clusterName -}}
{{- if $awsCluster -}}
  {{- /* First try to get from annotation (Giant Swarm specific) */ -}}
  {{- if $awsCluster.metadata.annotations -}}
    {{- $oidcProvider = index $awsCluster.metadata.annotations "aws.giantswarm.io/irsa-trust-domains" | default "" -}}
  {{- end -}}
  {{- /* If not found in annotation, try identity ref */ -}}
  {{- if and (not $oidcProvider) $awsCluster.spec.identityRef -}}
    {{- $identityName := $awsCluster.spec.identityRef.name -}}
    {{- $identityKind := $awsCluster.spec.identityRef.kind | default "AWSClusterControllerIdentity" -}}
    {{- if eq $identityKind "AWSClusterControllerIdentity" -}}
      {{- $identity := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSClusterControllerIdentity" "" $identityName -}}
      {{- if and $identity $identity.spec.oidc -}}
        {{- $oidcProvider = $identity.spec.oidc.issuerURL | trimPrefix "https://" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $oidcProvider -}}
{{- end -}}

{{/*
Merge tags from cluster CR with user-provided tags
Returns tags as a map: {foo: "bar"}
*/}}
{{- define "mimir.crossplane.tags" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
{{- $provider := .Values.crossplane.provider -}}
{{- $tags := dict -}}
{{- if eq $provider "aws" -}}
  {{- $awsCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSCluster" $clusterNamespace $clusterName -}}
  {{- if $awsCluster -}}
    {{- if $awsCluster.spec.additionalTags -}}
      {{- range $key, $value := $awsCluster.spec.additionalTags -}}
        {{- $_ := set $tags $key $value -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- else if eq $provider "azure" -}}
  {{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
  {{- if $azureCluster -}}
    {{- if $azureCluster.spec.additionalTags -}}
      {{- range $key, $value := $azureCluster.spec.additionalTags -}}
        {{- $_ := set $tags $key $value -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $defaultTags := dict
  "app" "mimir"
  "managed-by" "crossplane"
-}}
{{- $tags = merge $tags $defaultTags -}}
{{- $userTags := .Values.crossplane.tags | default list -}}
{{- range $tag := $userTags -}}
  {{- $_ := set $tags (index $tag "key") (index $tag "value") -}}
{{- end -}}
{{- $tags | toYaml -}}
{{- end -}}

{{/*
Crossplane simple labels for crossplane resources
*/}}
{{- define "mimir.crossplane.labels" -}}
helm.sh/chart: {{ include "mimir.chart" . }}
app.kubernetes.io/name: {{ include "mimir.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | default "atlas" | quote }}
{{- end -}}
