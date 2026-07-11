# --- LAYER DE BACKUP E DISASTER RECOVERY (AWS BACKUP & S3) ---

# Bucket S3 para armazenar os backups de estado do Cluster K8s (Velero / Snapshots)
resource "aws_s3_bucket" "k8s_backup_bucket" {
  bucket        = "solidary-tech-k8s-backups-production"
  force_destroy = false # Impede que o bucket com dados de segurança seja deletado acidentalmente
}

# Bloqueio de acesso público ao bucket de backup por motivos de DevSecOps
resource "aws_s3_bucket_public_access_block" "k8s_backup_bucket_privacy" {
  bucket = aws_s3_bucket.k8s_backup_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Ativação de versionamento no bucket (Proteção contra Ransomware/Deleção acidental)
resource "aws_s3_bucket_versioning" "k8s_backup_versioning" {
  bucket = aws_s3_bucket.k8s_backup_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# --- AWS BACKUP VAULT (Para automatizar a retenção e regras de backup do RDS) ---
resource "aws_backup_vault" "solidary_vault" {
  name        = "solidary-tech-backup-vault"
  kms_key_arn = "arn:aws:kms:us-east-1:aws:kms" # Utiliza chave nativa da AWS para criptografia de backups
}

# Plano de Backup Automatizado (Retenção e agendamento)
resource "aws_backup_plan" "solidary_backup_plan" {
  name = "solidary-tech-backup-plan"

  rule {
    rule_name         = "daily_backup_rule"
    target_vault_name = aws_backup_vault.solidary_vault.name
    schedule          = "cron(0 3 * * ? *)" # Executa todo dia às 03:00 AM (Horário de menor uso)

    lifecycle {
      delete_after = 30 # Retém os backups por 30 dias na nuvem antes de expirar (FinOps Control)
    }
  }
}
