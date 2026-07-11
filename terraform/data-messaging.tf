# --- LAYER DE MENSAGERIA (AWS SQS) ---
# Fila principal para processamento assíncrono de doações
resource "aws_sqs_queue" "donation_queue" {
  name                      = "solidary-tech-donation-queue.fifo"
  fifo_queue                = true
  content_based_deduplication = true
  message_retention_seconds = 86400 # Mantém a mensagem por 24h caso o microsserviço caia

  # Redrive policy para enviar mensagens com erro para a Dead Letter Queue (DLQ)
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.donation_dlq.arn
    maxReceiveCount     = 5 # Se falhar 5 vezes, vai para a DLQ para análise do time de SRE
  })
}

# Fila de Erros (Dead Letter Queue) para auditoria e resiliência
resource "aws_sqs_queue" "donation_dlq" {
  name       = "solidary-tech-donation-dlq.fifo"
  fifo_queue = true
}


# --- LAYER DE BANCO DE DADOS (AWS RDS POSTGRESQL) ---
# Grupo de subnets onde o RDS vai morar (obrigatoriamente subnets privadas para segurança)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "solidary-tech-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

# Security Group para o RDS aceitar conexões vindas apenas de dentro do cluster EKS
resource "aws_security_group" "rds_sg" {
  name        = "solidary-tech-rds-sg"
  description = "Permite acesso ao RDS a partir do cluster EKS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL do EKS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# Instância do RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier             = "solidary-tech-db"
  engine                 = "postgres"
  engine_version         = "16.1"
  instance_class         = "db.t3.micro" # FinOps: Entrada barata para demonstração/hackathon
  allocated_storage      = 20
  max_allocated_storage  = 100 # Auto-scaling de disco para evitar indisponibilidade
  storage_type           = "gp3"
  
  db_name                = "solidary_db"
  username               = "solidary_admin"
  password               = "MudarSenhaForte123!" # Em produção usar AWS Secrets Manager
  
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  multi_az               = false # Mudar para true em prod real se precisar de HA total no banco
}
