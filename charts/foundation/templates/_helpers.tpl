{{/* Generate basic labels */}}

{{- define "common.labels" }}
labels:
  chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
  release: {{ .Release.Name }}
  env: {{ .Values.global.env }}
  version: {{ .Chart.AppVersion}}
{{- end }}

{{- define "initial-setup.labels" }}
{{- include "common.labels" . }}
{{- end }}

{{- define "dns-creator.labels" }}
{{- include "common.labels" . }}
{{- end }}

{{- define "dns-creator.annotations" }}
annotations:
  "helm.sh/hook": post-install,post-upgrade
  "helm.sh/hook-weight": "0"
  "helm.sh/hook-delete-policy": hook-succeeded,hook-failed
{{- end }}
