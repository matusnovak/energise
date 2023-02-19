{{- define "init-mariadb-create" -}}
{{- $mariadb := ((.Values.server.isMariadb | default false) | ternary .Values .Values.global.mariadb) -}}
- name: "init-mariadb-create"
  image: "{{ $mariadb.server.image.name }}:{{ $mariadb.server.image.tag }}"
  imagePullPolicy: "{{ $mariadb.server.image.pullPolicy }}"
  command:
    - 'sh'
    - '-c'
    - |
      until mysql -u${MARIADB_USER} -p${MARIADB_PASSWORD} -h ${MARIADB_HOST} -e "SELECT 1"; do echo "waiting for database"; sleep 2; done;
      mysql -u${MARIADB_USER} -p${MARIADB_PASSWORD} -h ${MARIADB_HOST} mysql -e "CREATE DATABASE IF NOT EXISTS {{ .database.name }};";
      mysql -u${MARIADB_USER} -p${MARIADB_PASSWORD} -h ${MARIADB_HOST} mysql -e "CREATE USER IF NOT EXISTS '{{ .database.role }}'@'%' IDENTIFIED BY '{{ .database.password }}';";
      mysql -u${MARIADB_USER} -p${MARIADB_PASSWORD} -h ${MARIADB_HOST} mysql -e "GRANT ALL PRIVILEGES ON {{ .database.name }}.* TO '{{ .database.role }}'@'%' WITH GRANT OPTION;";
      mysql -u${MARIADB_USER} -p${MARIADB_PASSWORD} -h ${MARIADB_HOST} mysql -e "FLUSH PRIVILEGES;";
  env:
    - name: "MARIADB_USER"
      value: "root"
    - name: "MARIADB_HOST"
      value: "mariadb-server.{{ .Release.Namespace }}.svc.cluster.local"
    - name: "MARIADB_PASSWORD"
      valueFrom:
        secretKeyRef:
          name: "mariadb-server"
          key: "password"
          optional: false

{{- end }}
