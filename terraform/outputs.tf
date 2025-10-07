# Outputs pour les informations importantes du cluster

# Informations du VPC
output "vpc_id" {
  description = "ID du VPC Kubernetes"
  value       = aws_vpc.kubernetes_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block du VPC"
  value       = aws_vpc.kubernetes_vpc.cidr_block
}

# Informations des subnets
output "public_subnet_ids" {
  description = "IDs des subnets publics"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "IDs des subnets privés"
  value       = aws_subnet.private_subnets[*].id
}

# Informations des security groups
output "master_security_group_id" {
  description = "ID du security group des masters"
  value       = aws_security_group.kubernetes_master_sg.id
}

output "worker_security_group_id" {
  description = "ID du security group des workers"
  value       = aws_security_group.kubernetes_worker_sg.id
}

# Informations des instances master
output "master_instances" {
  description = "Informations des instances master"
  value = {
    for i, instance in aws_instance.kubernetes_master : i => {
      id         = instance.id
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
      public_dns = instance.public_dns
      az         = instance.availability_zone
    }
  }
}

# Informations des instances worker
output "worker_instances" {
  description = "Informations des instances worker"
  value = {
    for i, instance in aws_instance.kubernetes_worker : i => {
      id         = instance.id
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
      public_dns = instance.public_dns
      az         = instance.availability_zone
    }
  }
}

# Commandes SSH pour se connecter aux instances
output "ssh_commands" {
  description = "Commandes SSH pour se connecter aux instances"
  value = {
    masters = [
      for i, instance in aws_instance.kubernetes_master :
      "ssh -i ~/.ssh/${var.key_pair_name} ubuntu@${instance.public_ip}"
    ]
    workers = [
      for i, instance in aws_instance.kubernetes_worker :
      "ssh -i ~/.ssh/${var.key_pair_name} ubuntu@${instance.public_ip}"
    ]
  }
}

# URL de l'API Kubernetes (une fois le cluster initialisé)
output "kubernetes_api_endpoint" {
  description = "Endpoint de l'API Kubernetes"
  value       = "https://${aws_instance.kubernetes_master[0].public_ip}:6443"
}

# Informations pour Ansible
output "ansible_inventory" {
  description = "Informations pour générer l'inventaire Ansible"
  value = {
    masters = {
      for i, instance in aws_instance.kubernetes_master : 
      "${local.cluster_name}-master-${i + 1}" => {
        ansible_host = instance.public_ip
        private_ip   = instance.private_ip
        instance_id  = instance.id
      }
    }
    workers = {
      for i, instance in aws_instance.kubernetes_worker : 
      "${local.cluster_name}-worker-${i + 1}" => {
        ansible_host = instance.public_ip
        private_ip   = instance.private_ip
        instance_id  = instance.id
      }
    }
  }
}

# Adresses IP simplifiées
output "master_public_ips" {
  description = "Adresses IP publiques des masters"
  value       = aws_instance.kubernetes_master[*].public_ip
}

output "master_private_ips" {
  description = "Adresses IP privées des masters"
  value       = aws_instance.kubernetes_master[*].private_ip
}

output "worker_public_ips" {
  description = "Adresses IP publiques des workers"
  value       = aws_instance.kubernetes_worker[*].public_ip
}

output "worker_private_ips" {
  description = "Adresses IP privées des workers"
  value       = aws_instance.kubernetes_worker[*].private_ip
}

output "all_public_ips" {
  description = "Toutes les adresses IP publiques"
  value = {
    masters = aws_instance.kubernetes_master[*].public_ip
    workers = aws_instance.kubernetes_worker[*].public_ip
  }
}

# Informations de coût (estimation)
output "estimated_monthly_cost" {
  description = "Coût mensuel estimé (en USD, basé sur us-east-1)"
  value = {
    ec2_instances = "${var.master_count + var.worker_count} x ${var.instance_type} = ~$${(var.master_count + var.worker_count) * 8.5}/mois"
    ebs_storage   = "${(var.master_count + var.worker_count) * 20}GB = ~$${(var.master_count + var.worker_count) * 20 * 0.10}/mois"
    nat_gateway   = "1 x NAT Gateway = ~$32/mois"
    total_estimate = "~$${(var.master_count + var.worker_count) * 8.5 + (var.master_count + var.worker_count) * 2 + 32}/mois"
  }
}