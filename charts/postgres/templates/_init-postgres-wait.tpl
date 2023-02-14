{{- define "init-postgres-wait" -}}
{{- $postgres := ((.Values.server.isPostgres | default false) | ternary .Values .Values.global.postgres) -}}
- name: "init-postgres-wait"
  image: "{{ $postgres.server.image.name }}:{{ $postgres.server.image.tag }}"
  imagePullPolicy: "{{ $postgres.server.image.pullPolicy }}"
  command:
    - 'sh'
    - '-c'
    - |
      until psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_ROLE -d $POSTGRES_DB -c "select 1"; do echo "waiting for database"; sleep 2; done;
  env:
    - name: POSTGRES_HOST
      value: "postgres-server.{{ .Release.Namespace }}.svc.cluster.local"
    - name: POSTGRES_PORT
      value: "5432"
    - name: POSTGRES_ROLE
      value: "{{ $postgres.server.user }}"
    - name: POSTGRES_DB
      value: "{{ $postgres.server.database }}"
    - name: PGCONNECT_TIMEOUT
      value: "10"
    - name: PGPASSWORD
      valueFrom:
        secretKeyRef:
          name: "postgres-server"
          key: "password"
          optional: false
{{- end }}
