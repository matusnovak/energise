{{- define "init-openldap-create" -}}
{{ $openldap := (.Values.openldap | default .Values.global.openldap) -}}
- name: "init-openldap-create"
  image: "{{ $openldap.server.image.name }}:{{ $openldap.server.image.tag }}"
  imagePullPolicy: "{{ $openldap.server.image.pullPolicy }}"
  command:
    - '/bin/bash'
    - '-c'
    - |
      count=$(ldapsearch -x -H "ldap://$LDAP_HOST:389" -D "$LDAP_USER" -w "$LDAP_PASSWORD" -b "$LDAP_BASE" "(&(objectClass=groupOfUniqueNames)(cn={{ .group }}))" | grep dn: | wc -l);
      echo "dn: cn={{ .group }},ou=groups,{{ .Values.global.domainComponent }}" >> /tmp/group.ldif;
      echo "changetype: add" >> /tmp/group.ldif;
      echo "objectClass: top" >> /tmp/group.ldif;
      echo "objectClass: groupOfUniqueNames" >> /tmp/group.ldif;
      echo "uniqueMember: cn=readonly,{{ .Values.global.domainComponent }}" >> /tmp/group.ldif;
      echo "cn: {{ .group }}" >> /tmp/group.ldif;
      if [ "$count" == "0" ]; then ldapmodify -x -H "ldap://$LDAP_HOST:389" -D "$LDAP_USER" -w "$LDAP_PASSWORD" -f /tmp/group.ldif; fi;
  env:
    - name: LDAP_HOST
      value: "openldap-server.{{ .Release.Namespace }}.svc.cluster.local"
    - name: LDAP_USER
      value: "cn=admin,{{ .Values.global.domainComponent }}"
    - name: LDAP_PASSWORD
      valueFrom:
        secretKeyRef:
          name: "openldap-server"
          key: "password"
          optional: false
    - name: LDAP_BASE
      value: "{{ .Values.global.domainComponent }}"
{{- end }}
