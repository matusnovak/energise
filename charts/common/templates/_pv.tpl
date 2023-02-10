{{- define "pv-spec" }}
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ .Release.Namespace }}-{{ .Chart.Name }}-{{ .name }}
  labels:
    "app.kubernetes.io/managed-by": "{{ .Release.Service }}"
    "app.kubernetes.io/name": "{{ .Chart.Name }}"
    "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
    "app.kubernetes.io/version": "{{ .Chart.Version }}"
    "app.kubernetes.io/part-of": "{{ .Values.global.name }}"
spec:
  storageClassName: "{{ .storage.class | default .Values.global.storage.class }}"
  capacity:
    storage: "{{ .storage.capacity | default "1Gi" }}"
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "{{ .Values.global.storage.path }}/{{ .storage.dir }}"
{{- end }}
