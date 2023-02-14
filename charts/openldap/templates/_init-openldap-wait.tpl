{{- define "init-openldap-wait" -}}
{{- $openldap := ((.Values.server.isOpenLDAP | default false) | ternary .Values .Values.global.openldap) -}}
- name: "init-openldap-wait"
  image: "{{ $openldap.server.image.name }}:{{ $openldap.server.image.tag }}"
  imagePullPolicy: "{{ $openldap.server.image.pullPolicy }}"
  command:
    - 'sh'
    - '-c'
    - 'until ldapsearch -x -H "ldap://$LDAP_HOST:389" -D "$LDAP_USER" -w "$LDAP_PASSWORD" -b "$LDAP_BASE" -o nettimeout=1; do echo "waiting for openldap"; sleep 2; done;'
  env:
    - name: LDAP_HOST
      value: "openldap-server.{{ .Release.Namespace }}.svc.cluster.local"
    - name: LDAP_USER
      value: "cn=readonly,{{ .Values.global.domainComponent }}"
    - name: LDAP_PASSWORD
      valueFrom:
        secretKeyRef:
          name: "openldap-server"
          key: "readonlyPassword"
          optional: false
    - name: LDAP_BASE
      value: "{{ .Values.global.domainComponent }}"
{{- end }}
