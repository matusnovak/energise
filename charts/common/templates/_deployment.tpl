{{- define "deployment-spec" -}}
{{ $data := (index (index .Values .Chart.Name) .component) -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "{{ .Chart.Name }}-{{ .component }}{{ .suffix | default "" }}"
  namespace: "{{ .Release.Namespace }}"
  labels:
    "app.kubernetes.io/managed-by": "{{ .Release.Service }}"
    "app.kubernetes.io/name": "{{ .Chart.Name }}"
    "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
    "app.kubernetes.io/version": "{{ .Chart.Version }}"
    "app.kubernetes.io/part-of": "{{ .Values.global.name }}"
  {{- if or (.annotations) ($data.keel.enabled | default false) }}
  annotations:
  {{- if .annotations }}
    {{- toYaml .annotations | nindent 4 }}
  {{- end }}
  {{- if and ($data.keel.enabled | default false) }}
    "keel.sh/policy": "{{ $data.keel.policy | default "minor" }}"
    "keel.sh/trigger": "{{ $data.keel.trigger | default "poll" }}"
    "keel.sh/match-tag": "{{ $data.keel.matchTag | default "false" }}"
    "keel.sh/pollSchedule": "{{ $data.keel.pollSchedule | default "every 60m" }}"
  {{- end }}
  {{- end }}
{{- end }}
