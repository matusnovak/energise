{{- define "ingressroute-spec" }}
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
{{ include "metadata-spec" (dict 
  "Values" .Values
  "Release" .Release
  "Chart" .Chart
  "component" .component) }}
spec:
  entryPoints:
{{- if .Values.global.traefik.server.http.enabled }}
    - web
{{- end }}
{{- if .Values.global.traefik.server.https.enabled }}
    - websecure
{{- end }}
{{- if .Values.global.traefik.server.https.enabled }}
  tls:
{{- if eq .Values.global.traefik.server.certs.type "resolver" }}
    certResolver: resolver
{{- else }}
    { }
{{- end }}
{{- end }}
{{- end }}
