# 🛡️ Plano de Continuidade de Negócios (PCN) e Disaster Recovery - Solidary Tech

## 1. Definições de Objetivos de Recuperação (Métricas Críticas)
Para o ecossistema da Solidary Tech, com foco absoluto no processamento do fluxo financeiro do `donation-service`, estabelecemos as seguintes metas rígidas:

*   **RPO (Recovery Point Objective):** **5 minutos**. Máxima perda tolerável de dados de doações em caso de desastre severo. Os logs de transações e banco de dados precisam ter replicação quase síncrona.
*   **RTO (Recovery Time Objective):** **15 minutos**. Tempo máximo tolerável para o ambiente estar online e operacional novamente em outra região/infraestrutura após a queda do cluster principal.

## 2. Estratégia Prática de Disaster Recovery (Opção B - Warm Standby)
Adotamos a **Opção B (Infraestrutura Ativo-Passivo)** exigida no roteiro. 

*   **Mecanismo:** O código Terraform foi modularizado de forma que o provisionamento do cluster Kubernetes e da rede seja totalmente agnóstico de região[cite: 1].
*   **Ação de Contingência:** Em caso de desastre total na região principal (`us-east-1`), a esteira de automação ou o operador executa o Terraform apontando para a região secundária (`us-west-2`) com **apenas 1 comando**[cite: 1]: `terraform apply -var="region=us-west-2"`.
*   **Sincronismo:** Os dados críticos de doações utilizam replicação global multi-região nativa do banco de dados, garantindo o RPO de 5 minutos[cite: 1].
