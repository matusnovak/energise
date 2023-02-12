{{- define "service-spec" }}
apiVersion: v1
kind: Service
metadata:
  name: "{{ .Chart.Name }}-{{ .component }}{{ .suffix | default ""}}"
  namespace: "{{ .Release.Namespace }}"
  labels:
    "app.kubernetes.io/managed-by": "{{ .Release.Service }}"
    "app.kubernetes.io/name": "{{ .Chart.Name }}"
    "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
    "app.kubernetes.io/version": "{{ .Chart.Version }}"
    "app.kubernetes.io/part-of": "{{ .Values.global.name }}"
  {{- if .scrape }}
  annotations:
    "prometheus.io/scrape": "true"
    "prometheus.io.scheme": "http"
    "prometheus.io/port": "{{ .scrape }}"
    {{- if .scrapeUrl }}
    "prometheus.io/path": "{{ .scrapeUrl }}"
    {{- end }}
  {{- end }}
spec:
  type: {{ .service.type }}
  selector:
    "app.kubernetes.io/name": "{{ .Chart.Name }}"
    "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
{{- end }}
