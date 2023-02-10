{{- define "pvc-spec" }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .Chart.Name }}-{{ .name }}
  namespace: {{ .Release.Namespace }}
  labels:
    "app.kubernetes.io/managed-by": "{{ .Release.Service }}"
    "app.kubernetes.io/name": "{{ .Chart.Name }}"
    "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
    "app.kubernetes.io/version": "{{ .Chart.Version }}"
    "app.kubernetes.io/part-of": "{{ .Values.global.name }}"
spec:
  storageClassName: "{{ .storage.class | default .Values.global.storage.class }}"
  resources:
    requests:
        storage: "{{ .storage.capacity | default "1Gi" }}"
  accessModes:
    - ReadWriteMany
  volumeName: {{ .Release.Namespace }}-{{ .Chart.Name }}-{{ .name }}
{{- end }}
