terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  # --- EXIGÊNCIA DE FINOPS: TAGS RIGOROSAS DIRETAMENTE NA IAC ---
  default_tags {
    tags = {
      Project     = "Solidary Tech"
      Environment = "Production"
      CostCenter  = "NGO-Core"
      ManagedBy   = "Terraform"
    }
  }
}
