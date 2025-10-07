# Variables de configuration générale
variable "aws_region" {
  description = "Région AWS où déployer l'infrastructure"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Nom du cluster Kubernetes"
  type        = string
  default     = "k8s-cluster"
}

# Configuration réseau
variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks pour les subnets publics"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks pour les subnets privés"
  type        = list(string)
  default     = ["10.0.10.0/24"]
}

# Configuration des instances EC2
variable "instance_type" {
  description = "Type d'instance EC2 (free tier)"
  type        = string
  default     = "t2.micro"
}

variable "master_count" {
  description = "Nombre de nœuds master"
  type        = number
  default     = 1
}

variable "worker_count" {
  description = "Nombre de nœuds worker"
  type        = number
  default     = 3
}

variable "key_pair_name" {
  description = "Nom de la paire de clés SSH pour accéder aux instances"
  type        = string
  default     = "kubernetes-key"
}

# Configuration de sécurité
variable "allowed_cidr_blocks" {
  description = "CIDR blocks autorisés pour l'accès SSH et API Kubernetes"
  type        = list(string)
  default     = ["0.0.0.0/0"] # À modifier pour la production
}