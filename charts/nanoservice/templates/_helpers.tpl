

#-------------------------------------------------------------------------------
#---- DEFININDO LABELS                                                      ----
#-------------------------------------------------------------------------------

{{- define "common.labels" }}
labels:
  chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
  release: {{ .Release.Name }}
  env: {{ .Values.global.env }}
  version: {{ default .Values.global.appVersion "0.0.1"}}
{{- end }}

{{- define "all.labels" }}
{{- include "common.labels" . }}
{{- .Values.extra_labels }}
{{- end }}

{{- define "db-migrator.labels" }}
{{- include "common.labels" . }}
{{- end }}

#-------------------------------------------------------------------------------
#---- DEFININDO ANNOTATIONS                                                 ----
#-------------------------------------------------------------------------------

{{- define "common.annotations" }}
annotations:
  timestamp: {{ now | unixEpoch | quote }}
{{- end }}