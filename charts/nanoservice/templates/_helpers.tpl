
{{-
/* ------------------------------------------------------------------------------- */
/* --- DEFININDO LABELS                                                      ---- */
/* ------------------------------------------------------------------------------- */
-}}

{{ $app := printf "%s" .Release.Name | trunc 63 | trimSuffix "-" }}


{{- define "labels.common" }}
labels:
  chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
  release: {{ .Release.Name }}
  env: {{ .Values.global.env }}
  version: {{ .Chart.AppVersion}}
{{- end }}

{{- define "labels.all" }}
{{- include "labels.common" . }}
{{- include .Values.extra_labels . }}
{{- end }}

{{- define "sa-binder.labels" }}
{{- include "labels.common" . }}
{{- end }}

{{- define "db-migrator.labels" }}
{{- include "labels.common" . }}
{{- end }}

{{-
/* ------------------------------------------------------------------------------- */
/* --- DEFININDO ANNOTATIONS                                                      ---- */
/* ------------------------------------------------------------------------------- */
-}}

{{- define "annotations.common" }}
annotations:
  timestamp: {{ now | unixEpoch | quote }}
{{- end }}

{{- define "sa-binder.annotations" }}
annotations:
  "helm.sh/hook": pre-install,pre-upgrade
  "helm.sh/hook-weight": "-1000"
  "helm.sh/hook-delete-policy": hook-succeeded,hook-failed
{{- end }}
