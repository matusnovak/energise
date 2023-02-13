{{- define "metadata-spec" -}}
metadata:
  name: "{{ .Chart.Name }}-{{ .component }}{{ .suffix | default "" }}"
  namespace: "{{ .Release.Namespace }}"
  labels:
    "app.kubernetes.io/managed-by": "{{ .Release.Service }}"
    "app.kubernetes.io/name": "{{ .Chart.Name }}"
    "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
    "app.kubernetes.io/version": "{{ .Chart.Version }}"
    "app.kubernetes.io/part-of": "{{ .Values.global.name }}"
  {{- if or (.checksum) (.annotations) (.keel) }}
  annotations:
  {{- if .checksum }}
    "checksum/config": "{{ .checksum }}"
  {{- end }}
  {{- if .annotations }}
    {{- toYaml .annotations | nindent 4 }}
  {{- end }}
  {{- end }}
{{- end }}
