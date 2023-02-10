{{- define "service-spec" }}
apiVersion: v1
kind: Service
metadata:
  name: "{{ .Chart.Name }}-{{ .component }}"
  namespace: "{{ .Release.Namespace }}"
  labels:
    "app.kubernetes.io/managed-by": "{{ .Release.Service }}"
    "app.kubernetes.io/name": "{{ .Chart.Name }}"
    "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
    "app.kubernetes.io/version": "{{ .Chart.Version }}"
    "app.kubernetes.io/part-of": "{{ .Values.global.name }}"
spec:
  type: {{ .service.type }}
{{- with .ports }}
  ports:
{{- range . }}
    - port: {{ .port }}
      protocol: "{{ .protocol }}"
      name: "{{ .name }}"
{{- end }}
{{- end }}
  selector:
    "app.kubernetes.io/name": "{{ .Chart.Name }}"
    "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
{{- end }}
