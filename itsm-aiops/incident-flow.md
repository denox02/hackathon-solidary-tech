# 🧠 Gestão Preditiva de Incidentes (ITSM & AIOps) - Solidary Tech

## 1. Configuração de AIOps (Monitoramento Preditivo)
Utilizamos os recursos de inteligência artificial nativos da nossa ferramenta de APM (**Datadog Watchdog**). 
*   O Watchdog monitora continuamente o comportamento do `donation-service`. 
*   Ele estabelece uma linha de base (*baseline*) de latência e taxa de erros automaticamente, gerando alertas preditivos de anomalias comportamentais antes que os SLOs sejam violados ou os doadores sejam afetados.

## 2. Ciclo de Vida de um Incidente (Fluxo ITSM)
O fluxo operacional de tratamento de falhas da Solidary Tech segue as melhores práticas de ITSM:

[ DETECÇÃO ]  --> O Datadog Watchdog detecta anomalia preditiva de latência.
      |
[ TRIPAGEM ]  --> Alerta automático via Webhook é disparado para o canal de SRE (Slack/Discord).
      |
[ MITIGAÇÃO ] --> O time de SRE analisa os Traces e Logs correlacionados no APM. Se for erro de deploy, aciona o Rollback via ArgoCD.
      |
[ RESOLUÇÃO ] --> O ambiente retorna ao estado estável. O incidente é encerrado na plataforma.
      |
[ POST-MORTEM]--> Reunião com os engenheiros para documentar a causa raiz e evitar recorrência.
