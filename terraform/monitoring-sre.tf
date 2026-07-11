# --- LAYER DE OBSERVABILIDADE E MONITORAMENTO (SRE VIA DATADOG) ---

# Configuração extra do provedor Datadog (Garante que os monitores rodem em código)
terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
}

# 1. MONITOR DE LATÊNCIA (Golden Metric: Latency no Hot Path)
resource "datadog_monitor" "donation_latency_monitor" {
  name               = "[SRE] Alerta de Latência - donation-service"
  type               = "metric alert"
  message            = "⚠️ A latência de p95 do donation-service ultrapassou os 200ms aceitáveis do SLO! Verifique o APM e Traces imediatamente. @slack-sre-alerts"
  
  # Consulta que calcula a latência p95 do serviço nos últimos 5 minutos
  query              = "avg(last_5m):p95:trace.express.request.duration{service:donation-service,env:production} > 0.2"

  monitor_thresholds {
    critical = 0.2  # 200 milissegundos
    warning  = 0.15 # 150 milissegundos
  }

  tags = ["project:solidary-tech", "tier:sre", "metric:latency"]
}

# 2. MONITOR DE TAXA DE ERRO (Golden Metric: Errors - Queima de Error Budget)
resource "datadog_monitor" "donation_error_rate_monitor" {
  name               = "[SRE] Alerta de Taxa de Erro Elevada - donation-service"
  type               = "metric alert"
  message            = "🚨 Taxa de erro do donation-service acima de 1% nos últimos 5 minutos! Risco iminente de estourar o Error Budget mensal. @slack-sre-alerts"
  
  # Calcula a razão de erros sobre o total de requisições recebidas
  query              = "sum(last_5m):sum:trace.express.request.errors{service:donation-service,env:production}.as_count() / sum(last_5m):sum:trace.express.request.hits{service:donation-service,env:production}.as_count() > 0.01"

  monitor_thresholds {
    critical = 0.01  # 1% de erros
    warning  = 0.005 # 0.5% de erros
  }

  tags = ["project:solidary-tech", "tier:sre", "metric:errors"]
}
