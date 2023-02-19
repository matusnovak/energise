{{- define "job-storage" }}
{{ $data := (index .Values .component) -}}
{{- if (.storage.setup | default true) }}
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Chart.Name }}-{{ .component }}-{{ .name }}-job"
  namespace: "{{ .Release.Namespace }}"
  labels:
    "app.kubernetes.io/managed-by": "{{ .Release.Service }}"
    "app.kubernetes.io/name": "{{ .Chart.Name }}"
    "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
    "app.kubernetes.io/version": "{{ .Chart.Version }}"
    "app.kubernetes.io/part-of": "{{ .Values.global.name }}"
  annotations:
    "helm.sh/hook": "pre-install,pre-upgrade"
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": "before-hook-creation,hook-succeeded"
spec:
  template:
    metadata:
      name: "{{ .Chart.Name }}-{{ .component }}-{{ .name }}-job"
      labels:
        "app.kubernetes.io/managed-by": "{{ .Release.Service }}"
        "app.kubernetes.io/name": "{{ .Chart.Name }}"
        "app.kubernetes.io/instance": "{{ .Chart.Name }}-{{ .component }}"
        "app.kubernetes.io/version": "{{ .Chart.Version }}"
        "app.kubernetes.io/part-of": "{{ .Values.global.name }}"
    spec:
      restartPolicy: Never
      containers:
      - name: "storage-job"
        image: "{{ .Values.global.busybox.image.name }}:{{ .Values.global.busybox.image.tag }}"
        imagePullPolicy: "{{ .Values.global.busybox.image.pullPolicy }}"
        env:
          - name: "STORAGE_PATH"
            value: "/mnt/storage/{{ .storage.dir }}"
        command:
          - '/bin/sh'
          - '-c'
          - |
            set -xe;
            echo "Configuring storage";
            echo "Creating and configuring directory ${STORAGE_PATH}";
            mkdir -p "${STORAGE_PATH}";
            chown {{ .storage.uid | default $data.uid | default "1000" }}:{{ .storage.gid | default $data.gid | default "1000" }} "${STORAGE_PATH}";
            chmod {{ .storage.mode | default "755" }} "${STORAGE_PATH}";
        volumeMounts:
          - name: "storage-volume"
            mountPath: "/mnt/storage"
      volumes:
        - name: "storage-volume"
          hostPath:
            path: "{{ .storage.path | default .Values.global.storage.path }}"
            type: "Directory"
{{- end }}
{{- end }}
