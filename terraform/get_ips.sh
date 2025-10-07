#!/bin/bash

# Script pour récupérer les adresses IP des instances Kubernetes
# Usage: ./get_ips.sh

echo "========================================="
echo "🚀 Adresses IP du Cluster Kubernetes"
echo "========================================="

# Vérifier si Terraform a été appliqué
if [ ! -f "terraform.tfstate" ]; then
    echo "❌ Erreur: terraform.tfstate non trouvé. Lancez 'terraform apply' d'abord."
    exit 1
fi

# Récupérer les informations des instances master
echo ""
echo "📍 MASTER NODES:"
echo "=================="
terraform output -json master_instances | jq -r 'to_entries[] | "Master-\(.key | tonumber + 1): Public IP = \(.value.public_ip), Private IP = \(.value.private_ip)"'

# Récupérer les informations des instances worker
echo ""
echo "📍 WORKER NODES:"
echo "=================="
terraform output -json worker_instances | jq -r 'to_entries[] | "Worker-\(.key | tonumber + 1): Public IP = \(.value.public_ip), Private IP = \(.value.private_ip)"'

# Afficher les commandes SSH
echo ""
echo "📍 COMMANDES SSH:"
echo "=================="
terraform output -json ssh_commands | jq -r '.masters[] as $cmd | "Master: \($cmd)"'
terraform output -json ssh_commands | jq -r '.workers[] as $cmd | "Worker: \($cmd)"'

# Créer un fichier d'inventaire simple
echo ""
echo "📍 CRÉATION D'UN INVENTAIRE SIMPLE:"
echo "====================================="

cat > inventory.txt << EOF
# Inventaire Kubernetes - $(date)

[masters]
EOF

terraform output -json master_instances | jq -r 'to_entries[] | "\(.value.public_ip) # \(.value.private_ip)"' >> inventory.txt

cat >> inventory.txt << EOF

[workers]
EOF

terraform output -json worker_instances | jq -r 'to_entries[] | "\(.value.public_ip) # \(.value.private_ip)"' >> inventory.txt

echo "✅ Inventaire sauvegardé dans inventory.txt"

# Créer un fichier d'inventaire Ansible
echo ""
echo "📍 CRÉATION D'UN INVENTAIRE ANSIBLE:"
echo "===================================="

cat > ansible_inventory.yml << EOF
all:
  children:
    masters:
      hosts:
EOF

terraform output -json ansible_inventory | jq -r '.masters | to_entries[] | "        \(.key):\n          ansible_host: \(.value.ansible_host)\n          private_ip: \(.value.private_ip)\n          instance_id: \(.value.instance_id)"' >> ansible_inventory.yml

cat >> ansible_inventory.yml << EOF
    workers:
      hosts:
EOF

terraform output -json ansible_inventory | jq -r '.workers | to_entries[] | "        \(.key):\n          ansible_host: \(.value.ansible_host)\n          private_ip: \(.value.private_ip)\n          instance_id: \(.value.instance_id)"' >> ansible_inventory.yml

cat >> ansible_inventory.yml << EOF
  vars:
    ansible_user: ubuntu
    ansible_ssh_private_key_file: ~/.ssh/kubernetes-key
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOF

echo "✅ Inventaire Ansible sauvegardé dans ansible_inventory.yml"

echo ""
echo "========================================="
echo "✅ Informations récupérées avec succès!"
echo "========================================="