{{- define "clusterrole-spec" }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: "{{ .Release.Namespace }}-{{ .Chart.Name }}-{{ .component }}"
  labels:
    "app.kubernetes.io/managed-by": "{{ .Release.Service }}"
    "app.kubernetes.io/name": "{{ .Chart.Name }}"
    "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
    "app.kubernetes.io/version": "{{ .Chart.Version }}"
    "app.kubernetes.io/part-of": "{{ .Values.global.name }}"
{{- end }}
