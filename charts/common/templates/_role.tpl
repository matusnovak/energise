{{- define "role-spec" }}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: "{{ .Chart.Name }}-{{ .component }}"
  namespace: "{{ .Release.Namespace }}"
  labels:
    "app.kubernetes.io/managed-by": "{{ .Release.Service }}"
    "app.kubernetes.io/name": "{{ .Chart.Name }}"
    "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
    "app.kubernetes.io/version": "{{ .Chart.Version }}"
    "app.kubernetes.io/part-of": "{{ .Values.global.name }}"
rules:
  - apiGroups:
      - "extensions"
    resources:
      - "podsecuritypolicies"
    verbs:
      - "use"
    resourceNames:
      - "{{ .Chart.Name }}-{{ .component }}"
{{- end }}
