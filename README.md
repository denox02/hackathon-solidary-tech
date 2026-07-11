# 🚀 Hackathon - Solidary Tech (Fase 5 Concluída)

Este repositório contém a solução completa de infraestrutura como código (IaC), automação de deploy (GitOps), segurança (DevSecOps) e governança operacional (SRE/FinOps) para o ecossistema de microsserviços da **Solidary Tech**.

---

## 🏗️ 1. Arquitetura do Ecossistema e Persistência
A plataforma é composta por três aplicações críticas integradas a uma infraestrutura robusta na nuvem (AWS):
1.  **`donation-service`**: O **Hot Path (Caminho Crítico)**. Processa as doações de forma assíncrona utilizando uma fila de mensageria **AWS SQS FIFO** com tratamento de falhas via Dead Letter Queue (DLQ).
2.  **`ngo-service`**: Cadastro e gerenciamento das ONGs parceiras, conectado diretamente ao banco de dados relacional.
3.  **`volunteer-service`**: Match inteligente de voluntários, compartilhando a mesma camada segura de dados.

---

## 🛠️ 2. Engenharia e Governança Implementadas

### ☁️ Infraestrutura como Código (Terraform)
Localizado na pasta `/terraform`, o provisionamento cobre toda a topologia de rede e serviços necessários:
*   **VPC & Redes:** Divisão em subnets públicas e privadas distribuídas em múltiplas Zonas de Disponibilidade (AZs) para alta disponibilidade.
*   **EKS (Kubernetes):** Cluster gerenciado rodando na versão estável 1.30 com grupos de nós auto-escaláveis.
*   **Persistência & Mensageria:** Banco de Dados **RDS PostgreSQL 16** isolado em redes privadas e filas **SQS FIFO** com desduplicação nativa.
*   **FinOps Ativo:** Mapeamento do bloco global `default_tags` no provedor AWS, forçando o tagueamento automático de custos (`Project`, `Environment`, `CostCenter`). Uso estratégico de `single_nat_gateway` e instâncias otimizadas para balancear resiliência e orçamento.

### ☸️ GitOps & Declaração de Recursos (Kubernetes & ArgoCD)
*   **Rightsizing Computacional:** Todos os manifestos na pasta `/k8s` possuem limites restritos de `requests` e `limits` computacionais, prevenindo o desperdício por superdimensionamento (*over-provisioning*).
*   **Sincronismo via ArgoCD:** Configuração do `argocd-application.yaml` na raiz com políticas automáticas de poda (`prune`) e autocorreção (`selfHeal`), eliminando divergências de configuração manuais direto no cluster.
*   **Injeção Dinâmica:** Centralização de strings de conexão em ConfigMaps e credenciais confidenciais em K8s Secrets (`connection-config.yaml`).

### 🛡️ DevSecOps & Pipelines (GitHub Actions)
Dentro de `.github/workflows/`, as esteiras realizam validações em tempo real a cada push nas ramificações principais:
*   **Trivy SCA Scan:** Varredura estática de segurança diretamente no sistema de arquivos barrando o pipeline com `exit-code 1` caso encontre pacotes ou dependências com severidade Crítica ou Alta.

### 📈 3. SRE: Confiabilidade & Golden Metrics
*   **SLI/SLO de Disponibilidade:** Objetivo de **99.9%** de sucesso nas requisições mensais HTTP.
*   **SLI/SLO de Latência:** **95%** das transações de doação devem responder em tempo menor ou igual a **200ms**.
*   **Monitores Automatizados (IaC):** O arquivo `monitoring-sre.tf` provisiona diretamente via código os alarmes de Latência p95 e Taxa de Erros no Datadog, alertando o time via canais integrados (Slack) antes do estouro do Orçamento de Erro (*Error Budget*).

### 🛡️ 4. Disaster Recovery & Continuidade de Negócios (PCN)
*   **Métricas Operacionais:** RPO (Recovery Point Objective) de **5 minutos** e RTO (Recovery Time Objective) de **15 minutos** para o hot path.
*   **Proteção de Dados:** O arquivo `backup-dr.tf` cria políticas automatizadas de backup no **AWS Backup Vault** com retenção programada de 30 dias e provisiona um bucket S3 versionado e criptografado para persistência do estado do Kubernetes.
*   **Warm Standby:** Infraestrutura totalmente modularizada via Terraform, permitindo clonar ou migrar todo o ecossistema para uma região secundária da AWS mudando apenas um parâmetro de variável de região.
