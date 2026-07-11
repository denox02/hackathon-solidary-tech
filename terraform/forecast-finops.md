# 💰 Relatório de Forecast e Otimização FinOps - Solidary Tech

Este documento apresenta a projeção de custos (Forecast) para o novo ecossistema da Solidary Tech em ambiente de Produção na AWS (região `us-east-1`), alinhado com a política de Tagging e Rightsizing implementada.

## 1. Projeção Mensal de Custos (Forecast Base)

Considerando o cenário de alta disponibilidade e resiliência exigido pelo projeto (3 réplicas para o `donation-service` e 2 réplicas para os demais serviços), a estimativa de consumo utilizando recursos equivalentes ao ambiente produtivo é:

| Recurso AWS | Configuração / Justificativa | Custo Estimado Mensal |
| :--- | :--- | :--- |
| **Amazon EKS** | 1 Cluster (Control Plane público/privado para GitOps/ArgoCD). | ~$73.00 |
| **Amazon EC2** | 3 Instâncias `t3.medium` (Nós de processamento para os microsserviços). | ~$62.40 |
| **Amazon SQS** | Mensageria para desacoplamento do processamento de doações. | ~$0.00 (Free Tier) |
| **Amazon EBS (gp3)** | Volumes persistentes para armazenamento de logs e estado dos nós. | ~$15.00 |
| **AWS Data Transfer** | Tráfego de rede devido aos picos imprevisíveis de acesso. | ~$10.00 |
| **Total Projetado** | | **~$160.40 / mês** |

---

## 2. Governança e Alocação de Custos (Tagging)

Para que a diretoria da ONG tenha controle total de onde cada centavo está sendo investido, mapeamos globalmente as tags obrigatórias via Terraform[cite: 1]:
*   `Project = "Solidary Tech"`[cite: 1]
*   `Environment = "Production"`[cite: 1]
*   `CostCenter = "NGO-Core"`[cite: 1]

Isso garante a ativação imediata dos **Cost Allocation Tags** no AWS Billing, permitindo dashboards financeiros 100% transparentes.

---

## 3. Recomendação Prática de Otimização Nativa (FinOps)

Como o orçamento de uma ONG é estritamente limitado[cite: 1], a estratégia recomendada para redução imediata de custos sem perda de resiliência é a **Adoção de instâncias EC2 Spot para os Worker Nodes não-críticos**.

*   **Ação:** Configurar o cluster Kubernetes (EKS) para utilizar um Node Group misto. O `donation-service` (hot path crítico)[cite: 1] roda em instâncias instanciadas sob demanda (*On-Demand*), enquanto o `ngo-service` e `volunteer-service` rodam em instâncias *Spot*[cite: 1].
*   **Economia:** As instâncias Spot da AWS oferecem até **90% de desconto** em relação ao preço On-Demand para capacidade computacional ociosa. 
*   **Impacto Financeiro:** Redução estimada de até **40% no custo total de computação (EC2)** da plataforma, derrubando o custo operacional da infraestrutura para a casa dos **~$135.00/mês**.
