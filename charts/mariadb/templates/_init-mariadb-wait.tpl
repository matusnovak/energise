{{- define "init-mariadb-wait" -}}
{{- $mariadb := ((.Values.server.isMariadb | default false) | ternary .Values .Values.global.mariadb) -}}
- name: "init-mariadb-wait"
  image: "{{ $mariadb.server.image.name }}:{{ $mariadb.server.image.tag }}"
  imagePullPolicy: "{{ $mariadb.server.image.pullPolicy }}"
  command:
    - 'sh'
    - '-c'
    - |
      until mysql -u${MARIADB_USER} -p${MARIADB_PASSWORD} -h ${MARIADB_HOST} -e "SELECT 1"; do echo "waiting for database"; sleep 2; done;
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
