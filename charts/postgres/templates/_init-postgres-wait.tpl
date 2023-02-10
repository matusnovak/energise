{{- define "init-postgres-wait" -}}
- name: "init-postgres"
  image: "{{ .Values.postgres.server.image.name }}:{{ .Values.postgres.server.image.tag }}"
  imagePullPolicy: "{{ .Values.postgres.server.image.pullPolicy }}"
  command:
    - 'sh'
    - '-c'
    - |
      until psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_ROLE -d $POSTGRES_DB -c "select 1"; do echo "waiting for database"; sleep 2; done;
  env:
    - name: POSTGRES_HOST
      value: "{{ .Chart.Name }}-server.{{ .Release.Namespace }}.svc.cluster.local"
    - name: POSTGRES_PORT
      value: "{{ (index .Values.postgres.server.ports 0).port }}"
    - name: POSTGRES_ROLE
      value: "{{ .Values.postgres.server.user }}"
    - name: POSTGRES_DB
      value: "{{ .Values.postgres.server.database }}"
    - name: PGPASSWORD
      valueFrom:
        secretKeyRef:
          name: "{{ .Chart.Name }}-server"
          key: "password"
          optional: false
{{- end }}
