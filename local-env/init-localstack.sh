#!/bin/bash
echo "🚀 Inicializando serviços locais no LocalStack (AWS SQS)..."

# 1. Criar a Dead Letter Queue (DLQ) para falhas nas doações
awslocal sqs create-queue \
  --queue-name solidary-tech-donation-dlq.fifo \
  --attributes "FifoQueue=true,ContentBasedDeduplication=true"

# 2. Criar a Fila Principal (FIFO) apontando para a DLQ criada
awslocal sqs create-queue \
  --queue-name solidary-tech-donation-queue.fifo \
  --attributes '{
    "FifoQueue": "true",
    "ContentBasedDeduplication": "true",
    "RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:us-east-1:000000000000:solidary-tech-donation-dlq.fifo\",\"maxReceiveCount\":\"3\"}"
  }'

echo "✅ Filas SQS FIFO criadas com sucesso no ambiente local!"
