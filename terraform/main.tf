# Configuration du provider AWS
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables locales pour la configuration
locals {
  cluster_name = var.cluster_name
  common_tags = {
    Environment   = var.environment
    Project       = "kubernetes-cluster"
    ManagedBy     = "terraform"
    ClusterName   = local.cluster_name
  }
}

# Data source pour récupérer les zones de disponibilité
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC principal pour le cluster Kubernetes
resource "aws_vpc" "kubernetes_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-vpc"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  })
}