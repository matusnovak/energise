{{- define "init-postgres-create" -}}
{{ $postgres := (.Values.postgres | default .Values.global.postgres) -}}
- name: "init-postgres-create"
  image: "{{ $postgres.server.image.name }}:{{ $postgres.server.image.tag }}"
  imagePullPolicy: "{{ $postgres.server.image.pullPolicy }}"
  command:
    - 'sh'
    - '-c'
    - |
      echo "SELECT 'CREATE DATABASE {{ .database.name }}' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '{{ .database.name }}')\gexec" | psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_ROLE -d $POSTGRES_DB;
      echo "SELECT 'CREATE ROLE {{ .database.role }} WITH LOGIN PASSWORD ''{{ .database.password }}''' WHERE NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '{{ .database.role }}')\gexec" | psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_ROLE -d $POSTGRES_DB;
      echo "GRANT ALL PRIVILEGES ON DATABASE {{ .database.name }} TO {{ .database.role }}" | psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_ROLE -d $POSTGRES_DB;
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
