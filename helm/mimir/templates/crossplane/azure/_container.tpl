{{/*
Reusable Azure Storage Account template
Usage: {{ include "mimir.crossplane.azure.account" (dict "root" . "containerName" "my-container" "component" "mimir") }}
*/}}
{{- define "mimir.crossplane.azure.account" -}}
{{- $tags := include "mimir.crossplane.tags" .root | fromYaml }}
{{- $storageAccountName := include "mimir.crossplane.azure.storageAccountName" (dict "containerName" .containerName) }}
{{- $isPrivate := .root.Values.crossplane.private }}
---
apiVersion: storage.azure.upbound.io/v1beta2
kind: Account
metadata:
  name: {{ $storageAccountName }}
  namespace: {{ .root.Release.Namespace }}
  labels:
    {{- include "mimir.labels" (dict "ctx" .root "component" .component) | nindent 4 }}
  annotations:
    crossplane.io/external-name: {{ $storageAccountName }}
spec:
  managementPolicies:
    {{- if .root.Values.crossplane.observeOnly }}
    - Observe
    {{- else }}
    - "Create"
    - "Update"
    - "LateInitialize"
    - "Observe"
    {{- end }}
  forProvider:
    resourceGroupName: {{ .root.Values.crossplane.azure.resourceGroup }}
    location: {{ .root.Values.crossplane.region }}
    accountKind: StorageV2
    accountReplicationType: LRS
    accountTier: Standard
    allowBlobPublicAccess: false
    enableHttpsTrafficOnly: true
    minTlsVersion: TLS1_2
    publicNetworkAccessEnabled: {{ not $isPrivate }}
    {{- if $tags }}
    tags:
      {{- range $key, $value := $tags }}
      {{ $key }}: {{ $value | quote }}
      {{- end }}
      component: {{ .component | quote }}
    {{- end }}
  providerConfigRef:
    name: {{ .root.Values.crossplane.providerConfigRef }}
  writeConnectionSecretToRef:
    name: {{ .containerName }}
    namespace: {{ .root.Release.Namespace }}
{{- end -}}

{{/*
Reusable Azure Container template
Usage: {{ include "mimir.crossplane.azure.container" (dict "root" . "containerName" "my-container" "component" "mimir") }}
*/}}
{{- define "mimir.crossplane.azure.container" -}}
{{- $tags := include "mimir.crossplane.tags" .root | fromYaml }}
{{- $storageAccountName := include "mimir.crossplane.azure.storageAccountName" (dict "containerName" .containerName) }}
---
apiVersion: storage.azure.upbound.io/v1beta1
kind: Container
metadata:
  name: {{ .containerName }}
  namespace: {{ .root.Release.Namespace }}
  labels:
    {{- include "mimir.labels" (dict "ctx" .root "component" .component) | nindent 4 }}
  annotations:
    crossplane.io/external-name: {{ .containerName }}
spec:
  managementPolicies:
    {{- if .root.Values.crossplane.observeOnly }}
    - Observe
    {{- else }}
    - "Create"
    - "Update"
    - "LateInitialize"
    - "Observe"
    {{- end }}
  forProvider:
    storageAccountNameRef:
      name: {{ $storageAccountName }}
    containerAccessType: private
    {{- if $tags }}
    metadata:
      {{- range $key, $value := $tags }}
      {{ $key }}: {{ $value | quote }}
      {{- end }}
      component: {{ .component | quote }}
    {{- end }}
  providerConfigRef:
    name: {{ .root.Values.crossplane.providerConfigRef }}
{{- end -}}

{{/*
Reusable Azure ManagementPolicy (lifecycle) template
Usage: {{ include "mimir.crossplane.azure.lifecycle" (dict "root" . "containerName" "my-container" "component" "mimir" "lifecycleDays" 100) }}
*/}}
{{- define "mimir.crossplane.azure.lifecycle" -}}
{{- $storageAccountName := include "mimir.crossplane.azure.storageAccountName" (dict "containerName" .containerName) }}
---
apiVersion: storage.azure.upbound.io/v1beta2
kind: ManagementPolicy
metadata:
  name: {{ $storageAccountName }}
  namespace: {{ .root.Release.Namespace }}
  labels:
    {{- include "mimir.labels" (dict "ctx" .root "component" .component) | nindent 4 }}
  annotations:
    crossplane.io/external-name: {{ $storageAccountName }}-lifecycle
spec:
  managementPolicies:
    {{- if .root.Values.crossplane.observeOnly }}
    - Observe
    {{- else }}
    - "*"
    {{- end }}
  forProvider:
    storageAccountIdRef:
      name: {{ $storageAccountName }}
    rule:
      - name: DeleteOldBlobs
        enabled: true
        filters:
          blobTypes:
          - blockBlob
        actions:
          baseBlob:
            deleteAfterDaysSinceModificationGreaterThan: {{ .lifecycleDays | default 100 }}
  providerConfigRef:
    name: {{ .root.Values.crossplane.providerConfigRef }}
{{- end -}}

{{/*
Reusable Azure PrivateEndpoint template
Usage: {{ include "mimir.crossplane.azure.privateEndpoint" (dict "root" . "containerName" "my-container" "component" "mimir") }}
*/}}
{{- define "mimir.crossplane.azure.privateEndpoint" -}}
{{- $tags := include "mimir.crossplane.tags" .root | fromYaml }}
{{- $storageAccountName := include "mimir.crossplane.azure.storageAccountName" (dict "containerName" .containerName) }}
---
apiVersion: network.azure.upbound.io/v1beta1
kind: PrivateEndpoint
metadata:
  name: {{ .containerName }}
  namespace: {{ .root.Release.Namespace }}
  labels:
    {{- include "mimir.labels" (dict "ctx" .root "component" .component) | nindent 4 }}
  annotations:
    crossplane.io/external-name: {{ .containerName }}
spec:
  managementPolicies:
    {{- if .root.Values.crossplane.observeOnly }}
    - Observe
    {{- else }}
    - "*"
    {{- end }}
  forProvider:
    location: {{ .root.Values.crossplane.region }}
    resourceGroupName: {{ .root.Values.crossplane.azure.resourceGroup }}
    subnetId: {{ printf "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s-vnet/subnets/node-subnet" (include "mimir.crossplane.azure.subscriptionId" .root) .root.Values.crossplane.azure.resourceGroup .root.Values.crossplane.azure.resourceGroup }}
    privateDnsZoneGroup:
      - name: default
        privateDnsZoneIdsRefs:
          - name: {{ .root.Values.crossplane.clusterName }}-privatelink.blob.core.windows.net
    privateServiceConnection:
      - name: {{ .containerName }}
        isManualConnection: false
        privateConnectionResourceId: {{ printf "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Storage/storageAccounts/%s" (include "mimir.crossplane.azure.subscriptionId" .root) .root.Values.crossplane.azure.resourceGroup $storageAccountName }}
        subresourceNames:
          - blob
    {{- if $tags }}
    tags:
      {{- range $key, $value := $tags }}
      {{ $key }}: {{ $value | quote }}
      {{- end }}
      component: {{ .component | quote }}
    {{- end }}
  providerConfigRef:
    name: {{ .root.Values.crossplane.providerConfigRef }}
{{- end -}}
