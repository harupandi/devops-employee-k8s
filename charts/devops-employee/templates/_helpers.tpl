{{/*
Common labels applied to every resource in this chart.
Component-specific templates add `app.kubernetes.io/component: <backend|frontend>`
on top of this via `include`.
*/}}
{{- define "devops-employee.labels" -}}
app.kubernetes.io/part-of: {{ .Chart.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}
