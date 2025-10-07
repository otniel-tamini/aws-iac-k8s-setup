#!/bin/bash

# Script de déploiement complet du cluster Kubernetes
# Usage: ./deploy.sh

set -e

echo "🚀 Déploiement du cluster Kubernetes sur AWS"
echo "=============================================="

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages colorés
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérification des prérequis
log_info "Vérification des prérequis..."

# Vérifier Ansible
if ! command -v ansible &> /dev/null; then
    log_error "Ansible n'est pas installé"
    exit 1
fi

# Vérifier jq
if ! command -v jq &> /dev/null; then
    log_error "jq n'est pas installé"
    exit 1
fi

# Vérifier Terraform
if [ ! -f "../terraform/terraform.tfstate" ]; then
    log_error "Infrastructure Terraform non déployée"
    log_info "Veuillez d'abord exécuter 'terraform apply' dans le dossier terraform/"
    exit 1
fi

log_success "Prérequis vérifiés"

# Génération de l'inventaire
log_info "Génération de l'inventaire depuis Terraform..."
./generate_inventory.sh

# Test de connectivité
log_info "Test de connectivité vers les nœuds..."
if ansible all -i inventories/terraform_inventory.yml -m ping --timeout=30; then
    log_success "Connectivité OK"
else
    log_error "Problème de connectivité"
    log_info "Vérifiez que les instances sont démarrées et les clés SSH configurées"
    exit 1
fi

# Demande de confirmation
echo ""
read -p "🤔 Voulez-vous déployer le cluster Kubernetes ? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warning "Déploiement annulé"
    exit 0
fi

# Déploiement du cluster
log_info "Démarrage du déploiement du cluster..."
echo ""

if ansible-playbook -i inventories/terraform_inventory.yml playbooks/site.yml; then
    log_success "🎉 Cluster Kubernetes déployé avec succès !"
    
    echo ""
    echo "📋 Informations importantes :"
    echo "=============================="
    
    # Récupération de l'IP du master
    MASTER_IP=$(ansible masters -i inventories/terraform_inventory.yml --list-hosts | grep -v "hosts" | xargs | cut -d' ' -f1)
    MASTER_PUBLIC_IP=$(grep -A 1 "$MASTER_IP:" inventories/terraform_inventory.yml | grep "ansible_host:" | awk '{print $2}')
    
    echo "🎛️  API Kubernetes : https://$MASTER_PUBLIC_IP:6443"
    echo "🔑 Configuration kubectl : /etc/kubernetes/admin.conf"
    echo ""
    echo "🔧 Commandes utiles :"
    echo "ssh -i ~/.ssh/id_rsa ubuntu@$MASTER_PUBLIC_IP"
    echo "kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes"
    echo ""
    echo "📚 Documentation complète dans README.md"
    
else
    log_error "Échec du déploiement"
    echo ""
    echo "🔍 Pour déboguer :"
    echo "- Vérifiez les logs Ansible ci-dessus"
    echo "- Testez la connectivité : ansible all -i inventories/terraform_inventory.yml -m ping"
    echo "- Consultez les logs système : journalctl -u kubelet"
    exit 1
fi