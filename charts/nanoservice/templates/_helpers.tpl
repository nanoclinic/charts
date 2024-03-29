

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
  helm.sh/hook: pre-install,pre-upgrade
  helm.sh/hook-weight: "1"
  helm.sh/hook-delete-policy: hook-succeeded,hook-failed
{{- end }}

{{- define "sa.annotations" }}
annotations:
  iam.gke.io/gcp-service-account: {{ printf "%s@%s.iam.gserviceaccount.com" .Values.serviceAccount .Values.global.project_id }}
  helm.sh/hook: pre-install
  helm.sh/hook-weight: "0"
  helm.sh/hook-delete-policy: hook-failed
{{- end }}
