
{{/*
Crossplane enabled check
*/}}
{{- define "mimir.crossplane.enabled" -}}
{{- if and .Values.crossplane.enabled .Values.crossplane.clusterName -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Crossplane is AWS/CAPA
*/}}
{{- define "mimir.crossplane.isAWS" -}}
{{- if eq .Values.crossplane.provider "aws" -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Crossplane is Azure/CAPZ
*/}}
{{- define "mimir.crossplane.isAzure" -}}
{{- if eq .Values.crossplane.provider "azure" -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Merge tags from cluster CR with user-provided tags
Returns tags as a map: {foo: "bar"}
*/}}
{{- define "mimir.crossplane.tags" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
{{- $storageProvider := .Values.crossplane.provider -}}
{{- $clusterProvider := .Values.crossplane.clusterProvider | default $storageProvider -}}
{{- $tags := dict -}}
{{- if eq $clusterProvider "aws" -}}
  {{- $awsCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta2" "AWSCluster" $clusterNamespace $clusterName -}}
  {{- if $awsCluster -}}
    {{- if $awsCluster.spec.additionalTags -}}
      {{- range $key, $value := $awsCluster.spec.additionalTags -}}
        {{- $_ := set $tags $key $value -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- else if eq $clusterProvider "azure" -}}
  {{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
  {{- if $azureCluster -}}
    {{- if $azureCluster.spec.additionalTags -}}
      {{- range $key, $value := $azureCluster.spec.additionalTags -}}
        {{- $_ := set $tags $key $value -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- else if eq $clusterProvider "vsphere" -}}
  {{- $vsphereCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "VSphereCluster" $clusterNamespace $clusterName -}}
  {{- if $vsphereCluster -}}
    {{- if $vsphereCluster.spec.additionalTags -}}
      {{- range $key, $value := $vsphereCluster.spec.additionalTags -}}
        {{- $_ := set $tags $key $value -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- else if eq $clusterProvider "cloud-director" -}}
  {{- $vcdCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "VCDCluster" $clusterNamespace $clusterName -}}
  {{- if $vcdCluster -}}
    {{- if $vcdCluster.spec.additionalTags -}}
      {{- range $key, $value := $vcdCluster.spec.additionalTags -}}
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
{{- if eq $storageProvider "azure" -}}
{{- $sanitizedTags := dict -}}
{{- range $key, $value := $tags -}}
{{- $sanitizedKey := $key | replace "-" "_" -}}
{{- $_ := set $sanitizedTags $sanitizedKey $value -}}
{{- end -}}
{{- $sanitizedTags | toYaml -}}
{{- else -}}
{{- $tags | toYaml -}}
{{- end -}}
{{- end -}}
