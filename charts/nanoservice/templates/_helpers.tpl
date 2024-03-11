

#-------------------------------------------------------------------------------
#---- DEFININDO LABELS                                                      ----
#-------------------------------------------------------------------------------

{{- define "common.labels" }}
labels:
  chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
  release: {{ .Release.Name }}
  env: {{ .Values.global.env }}
  version: {{ default .Values.global.app_version "0.0.1" }}
{{- end }}

{{- define "all.labels" }}
{{- include "common.labels" . }}
{{- end }}

{{- define "migration.labels" }}
{{- include "common.labels" . }}
  app: {{ printf "%s-migration" .Release.Name }}
{{- end }}

#-------------------------------------------------------------------------------
#---- DEFININDO ANNOTATIONS                                                 ----
#-------------------------------------------------------------------------------

{{- define "common.annotations" }}
annotations:
  timestamp: {{ now | unixEpoch | quote }}
{{- end }}

{{- define "migration.annotations" }}
annotations:
  "helm.sh/hook": pre-install,pre-upgrade
  "helm.sh/hook-weight": "-100"
  "helm.sh/hook-delete-policy": hook-succeeded,hook-failed
{{- end }}
