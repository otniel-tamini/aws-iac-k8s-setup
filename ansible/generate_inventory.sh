#!/bin/bash

# Script pour générer l'inventaire Ansible depuis les outputs Terraform
# Usage: ./generate_inventory.sh

set -e

TERRAFORM_DIR="../terraform"
INVENTORY_FILE="inventories/terraform_inventory.yml"

echo "🔄 Génération de l'inventaire Ansible depuis Terraform..."

# Vérifier que Terraform a été appliqué
if [ ! -f "$TERRAFORM_DIR/terraform.tfstate" ]; then
    echo "❌ Erreur: terraform.tfstate non trouvé dans $TERRAFORM_DIR"
    echo "   Veuillez d'abord exécuter 'terraform apply' dans le dossier terraform/"
    exit 1
fi

# Vérifier que jq est installé
if ! command -v jq &> /dev/null; then
    echo "❌ Erreur: jq n'est pas installé"
    echo "   Installez jq avec: sudo apt install jq"
    exit 1
fi

# Créer le répertoire inventories s'il n'existe pas
mkdir -p inventories

echo "📋 Récupération des informations Terraform..."

# Récupérer les outputs Terraform
cd $TERRAFORM_DIR
MASTERS_JSON=$(terraform output -json master_instances)
WORKERS_JSON=$(terraform output -json worker_instances)
cd - > /dev/null

echo "📝 Génération de l'inventaire YAML..."

# Générer l'inventaire YAML
cat > $INVENTORY_FILE << EOF
---
# Inventaire généré automatiquement depuis Terraform
# Généré le: $(date)
# Ne pas modifier manuellement - utiliser ./generate_inventory.sh

all:
  children:
    masters:
      hosts:
EOF

# Ajouter les masters
echo "$MASTERS_JSON" | jq -r 'to_entries[] | "        k8s-cluster-master-\(.key | tonumber + 1):\n          ansible_host: \(.value.public_ip)\n          private_ip: \(.value.private_ip)\n          instance_id: \(.value.id)\n          availability_zone: \(.value.az)"' >> $INVENTORY_FILE

cat >> $INVENTORY_FILE << EOF
    workers:
      hosts:
EOF

# Ajouter les workers
echo "$WORKERS_JSON" | jq -r 'to_entries[] | "        k8s-cluster-worker-\(.key | tonumber + 1):\n          ansible_host: \(.value.public_ip)\n          private_ip: \(.value.private_ip)\n          instance_id: \(.value.id)\n          availability_zone: \(.value.az)"' >> $INVENTORY_FILE

cat >> $INVENTORY_FILE << EOF
  vars:
    ansible_user: ubuntu
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    ansible_python_interpreter: /usr/bin/python3
EOF

echo "✅ Inventaire généré avec succès: $INVENTORY_FILE"

# Afficher l'inventaire généré
echo ""
echo "📊 Inventaire généré:"
echo "====================="
cat $INVENTORY_FILE

echo ""
echo "🔍 Test de connectivité (optionnel):"
echo "====================================="
echo "ansible all -i $INVENTORY_FILE -m ping"

echo ""
echo "🚀 Pour déployer le cluster:"
echo "============================"
echo "ansible-playbook -i $INVENTORY_FILE playbooks/site.yml"