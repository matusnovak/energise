{{- define "rolebinding-spec" }}
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: "{{ .Chart.Name }}-{{ .component }}"
  namespace: "{{ .Release.Namespace }}"
  labels:
    "app.kubernetes.io/managed-by": "{{ .Release.Service }}"
    "app.kubernetes.io/name": "{{ .Chart.Name }}"
    "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
    "app.kubernetes.io/version": "{{ .Chart.Version }}"
    "app.kubernetes.io/part-of": "{{ .Values.global.name }}"
subjects:
  - kind: ServiceAccount
    namespace: "{{ .Release.Namespace }}"
    name: "{{ .Chart.Name }}-{{ .component }}"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: "{{ .Chart.Name }}-{{ .component }}"
{{- end }}
