{{- define "selector-spec" -}}
selector:
  matchLabels:
    "app.kubernetes.io/name": "{{ .Chart.Name }}"
    "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
{{- end }}
