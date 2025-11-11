{{- define "mon-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 -}}
{{- end -}}

{{- define "mon-app.fullname" -}}
{{- printf "%s" (include "mon-app.name" .) -}}
{{- end -}}
