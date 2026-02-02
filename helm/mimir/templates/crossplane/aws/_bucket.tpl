{{/*
Reusable S3 Bucket template
Usage: {{ include "mimir.crossplane.bucket" (dict "root" . "bucketName" "my-bucket" "component" "mimir" "bucketTags" .Values.crossplane.aws.mimir.tags) }}
*/}}
{{- define "mimir.crossplane.bucket" -}}
{{- $globalTags := include "mimir.crossplane.tags" .root | fromYaml }}
{{- $bucketTagsMap := dict }}
{{- range $tag := (.bucketTags | default list) }}
  {{- $_ := set $bucketTagsMap (index $tag "key") (index $tag "value") }}
{{- end }}
{{- $tags := merge $bucketTagsMap $globalTags }}
---
apiVersion: s3.aws.upbound.io/v1beta2
kind: Bucket
metadata:
  name: {{ .bucketName }}
  namespace: {{ .root.Release.Namespace }}
  labels:
    {{- include "mimir.labels" (dict "ctx" .root "component" .component) | nindent 4 }}
  annotations:
    crossplane.io/external-name: {{ .bucketName }}
spec:
  managementPolicies:
    {{- if .root.Values.crossplane.observeOnly }}
    - Observe
    {{- else }}
    - "*"
    {{- end }}
  forProvider:
    forceDestroy: false
    objectLockEnabled: false
    region: {{ .root.Values.crossplane.region }}
    tags:
      {{- range $key, $value := $tags }}
      {{ $key }}: {{ $value | quote }}
      {{- end }}
      component: {{ .component | quote }}
  providerConfigRef:
    name: {{ .root.Values.crossplane.providerConfigRef }}
{{- end -}}

{{/*
Reusable BucketLifecycleConfiguration template
Usage: {{ include "mimir.crossplane.bucketLifecycle" (dict "root" . "bucketName" "my-bucket" "component" "mimir" "lifecycleDays" 100) }}
*/}}
{{- define "mimir.crossplane.bucketLifecycle" -}}
---
apiVersion: s3.aws.upbound.io/v1beta1
kind: BucketLifecycleConfiguration
metadata:
  name: {{ .bucketName }}
  namespace: {{ .root.Release.Namespace }}
  annotations:
    crossplane.io/external-name: {{ .bucketName }}
  labels:
    {{- include "mimir.labels" (dict "ctx" .root "component" .component) | nindent 4 }}
spec:
  managementPolicies:
    {{- if .root.Values.crossplane.observeOnly }}
    - Observe
    {{- else }}
    - "*"
    {{- end }}
  forProvider:
    bucketRef:
      name: {{ .bucketName }}
    region: {{ .root.Values.crossplane.region }}
    rule:
      - id: Expiration
        status: Enabled
        expiration:
          - days: {{ .lifecycleDays | default 100 }}
  providerConfigRef:
    name: {{ .root.Values.crossplane.providerConfigRef }}
{{- end -}}

{{/*
Reusable BucketPublicAccessBlock template
Usage: {{ include "mimir.crossplane.bucketPublicAccessBlock" (dict "root" . "bucketName" "my-bucket" "component" "mimir") }}
*/}}
{{- define "mimir.crossplane.bucketPublicAccessBlock" -}}
---
apiVersion: s3.aws.upbound.io/v1beta1
kind: BucketPublicAccessBlock
metadata:
  name: {{ .bucketName }}
  namespace: {{ .root.Release.Namespace }}
  annotations:
    crossplane.io/external-name: {{ .bucketName }}
  labels:
    {{- include "mimir.labels" (dict "ctx" .root "component" .component) | nindent 4 }}
spec:
  managementPolicies:
    {{- if .root.Values.crossplane.observeOnly }}
    - Observe
    {{- else }}
    - "*"
    {{- end }}
  forProvider:
    bucketRef:
      name: {{ .bucketName }}
    region: {{ .root.Values.crossplane.region }}
    blockPublicAcls: true
    blockPublicPolicy: true
    ignorePublicAcls: true
    restrictPublicBuckets: true
  providerConfigRef:
    name: {{ .root.Values.crossplane.providerConfigRef }}
{{- end -}}

{{/*
Reusable BucketPolicy template (SSL enforcement)
Usage: {{ include "mimir.crossplane.bucketPolicy" (dict "root" . "bucketName" "my-bucket" "component" "mimir") }}
*/}}
{{- define "mimir.crossplane.bucketPolicy" -}}
{{- $isChinaRegion := hasPrefix "cn-" .root.Values.crossplane.region }}
---
apiVersion: s3.aws.upbound.io/v1beta1
kind: BucketPolicy
metadata:
  name: {{ .bucketName }}
  namespace: {{ .root.Release.Namespace }}
  labels:
    {{- include "mimir.labels" (dict "ctx" .root "component" .component) | nindent 4 }}
  annotations:
    crossplane.io/external-name: {{ .bucketName }}
spec:
  managementPolicies:
    {{- if .root.Values.crossplane.observeOnly }}
    - Observe
    {{- else }}
    - "*"
    {{- end }}
  forProvider:
    bucketRef:
      name: {{ .bucketName }}
    policy: |
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Sid": "EnforceSSLOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": ["s3:*"],
            "Resource": [
              "arn:aws{{- if $isChinaRegion }}-cn{{- end }}:s3:::{{ .bucketName }}",
              "arn:aws{{- if $isChinaRegion }}-cn{{- end }}:s3:::{{ .bucketName }}/*"
            ],
            "Condition": {
              "Bool": {
                "aws:SecureTransport": "false"
              }
            }
          }
        ]
      }
    region: {{ .root.Values.crossplane.region }}
  providerConfigRef:
    name: {{ .root.Values.crossplane.providerConfigRef }}
{{- end -}}

{{/*
Reusable IAM Role template with inline S3 policy
Usage: {{ include "mimir.crossplane.iamRole" (dict "root" . "bucketNames" (list "bucket1" "bucket2") "roleName" "my-role" "component" "mimir" "serviceAccount" "mimir" "bucketTags" .Values.crossplane.aws.mimir.tags) }}
*/}}
{{- define "mimir.crossplane.iamRole" -}}
{{- $globalTags := include "mimir.crossplane.tags" .root | fromYaml }}
{{- $bucketTagsMap := dict }}
{{- range $tag := (.bucketTags | default list) }}
  {{- $_ := set $bucketTagsMap (index $tag "key") (index $tag "value") }}
{{- end }}
{{- $tags := merge $bucketTagsMap $globalTags }}
{{- $oidcProvider := include "mimir.crossplane.aws.oidcProvider" .root }}
{{- $isChinaRegion := hasPrefix "cn-" .root.Values.crossplane.region }}
{{- $awsPartition := ternary "aws-cn" "aws" $isChinaRegion }}
---
apiVersion: iam.aws.upbound.io/v1beta1
kind: Role
metadata:
  name: {{ .roleName }}
  namespace: {{ .root.Release.Namespace }}
  labels:
    {{- include "mimir.labels" (dict "ctx" .root "component" .component) | nindent 4 }}
  annotations:
    crossplane.io/external-name: {{ .roleName }}
spec:
  managementPolicies:
    {{- if .root.Values.crossplane.observeOnly }}
    - Observe
    {{- else }}
    - "*"
    {{- end }}
  forProvider:
    assumeRolePolicy: |
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Principal": {
              "Federated": "arn:{{ $awsPartition }}:iam::{{ include "mimir.crossplane.aws.accountId" .root }}:oidc-provider/{{ $oidcProvider }}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
              "StringEquals": {
                "{{ $oidcProvider }}:sub": "system:serviceaccount:{{ .root.Release.Namespace }}:{{ .serviceAccount }}",
                "{{ $oidcProvider }}:aud": "sts.amazonaws.com{{- if $isChinaRegion }}.cn{{- end }}"
              }
            }
          }
        ]
      }
    inlinePolicy:
      - name: {{ .roleName }}
        policy: |
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Effect": "Allow",
                "Action": [
                  "s3:ListBucket",
                  "s3:PutObject",
                  "s3:GetObject",
                  "s3:DeleteObject"
                ],
                "Resource": [
                  {{- $bucketCount := len .bucketNames }}
                  {{- range $i, $bucket := .bucketNames }}
                  "arn:{{ $awsPartition }}:s3:::{{ $bucket }}",
                  "arn:{{ $awsPartition }}:s3:::{{ $bucket }}/*"{{- if lt (add $i 1) $bucketCount }},{{- end }}
                  {{- end }}
                ]
              },
              {
                "Effect": "Allow",
                "Action": [
                  "s3:GetAccessPoint",
                  "s3:GetAccountPublicAccessBlock",
                  "s3:ListAccessPoints"
                ],
                "Resource": "*"
              }
            ]
          }
    tags:
      {{- range $key, $value := $tags }}
      {{ $key }}: {{ $value | quote }}
      {{- end }}
      component: {{ .component | quote }}
  providerConfigRef:
    name: {{ .root.Values.crossplane.providerConfigRef }}
{{- end -}}
