{{/*
Sanitize storage account name for Azure
Azure storage account names must be:
- Between 3 and 24 characters
- Lowercase letters and numbers only
- Globally unique
*/}}
{{- define "mimir.crossplane.azure.storageAccountName" -}}
{{- $containerName := .containerName -}}
{{- $sanitized := regexReplaceAll "[^a-z0-9]" (lower $containerName) "" -}}
{{- $sanitized | trunc 24 -}}
{{- end -}}

{{/*
Storage account name of a component (mimir, ruler or alertmanager): its
crossplane.azure.<component>.storageAccountName, else derived from the container name.
Usage: {{ include "mimir.crossplane.azure.componentStorageAccountName" (dict "root" . "component" "ruler" "containerName" "my-container") }}
*/}}
{{- define "mimir.crossplane.azure.componentStorageAccountName" -}}
{{- $override := (index .root.Values.crossplane.azure .component).storageAccountName | default "" -}}
{{- if $override -}}
{{- if not (regexMatch "^[a-z0-9]{3,24}$" $override) -}}
{{- fail (printf "crossplane.azure.%s.storageAccountName %q must be 3 to 24 lowercase letters and digits" .component $override) -}}
{{- end -}}
{{- $override -}}
{{- else -}}
{{- include "mimir.crossplane.azure.storageAccountName" (dict "containerName" .containerName) -}}
{{- end -}}
{{- end -}}

{{/*
Fails when two components resolve to the same storage account. Derived names are
cut to 24 characters, so long installation names make them collide, e.g.
giantswarm-graceland-mimir and giantswarm-graceland-mimir-ruler.
*/}}
{{- define "mimir.crossplane.azure.checkStorageAccountNames" -}}
{{- $seen := dict -}}
{{- range $component := list "mimir" "ruler" "alertmanager" -}}
{{- $containerName := (index $.Values.crossplane.azure $component).name -}}
{{- if $containerName -}}
{{- $account := include "mimir.crossplane.azure.componentStorageAccountName" (dict "root" $ "component" $component "containerName" $containerName) -}}
{{- if hasKey $seen $account -}}
{{- fail (printf "crossplane.azure: %s and %s both use storage account %q (derived names are the container name without hyphens, cut to 24 characters); set crossplane.azure.%s.storageAccountName" (get $seen $account) $component $account $component) -}}
{{- end -}}
{{- $_ := set $seen $account $component -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Get Azure Subscription ID from values or AzureCluster CR
*/}}
{{- define "mimir.crossplane.azure.subscriptionId" -}}
{{- $clusterName := .Values.crossplane.clusterName -}}
{{- $clusterNamespace := .Values.crossplane.clusterNamespace -}}
{{- $subscriptionId := .Values.crossplane.azure.subscriptionId | default "" -}}
{{- if not $subscriptionId -}}
  {{- $azureCluster := lookup "infrastructure.cluster.x-k8s.io/v1beta1" "AzureCluster" $clusterNamespace $clusterName -}}
  {{- if $azureCluster -}}
    {{- $subscriptionId = $azureCluster.spec.subscriptionID -}}
  {{- end -}}
{{- end -}}
{{- $subscriptionId -}}
{{- end -}}
