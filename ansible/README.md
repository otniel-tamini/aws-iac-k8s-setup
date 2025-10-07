# Configuration Ansible pour Kubernetes

Ce dossier contient tous les fichiers Ansible nécessaires pour déployer automatiquement un cluster Kubernetes sur l'infrastructure AWS créée par Terraform.

## 📁 Structure

```
ansible/
├── playbooks/
│   ├── site.yml              # Playbook principal de déploiement
│   ├── ping.yml              # Test de connectivité
│   └── reset.yml             # Réinitialisation du cluster
├── roles/
│   ├── common/               # Préparation des nœuds (swap, containerd, etc.)
│   ├── kubernetes/           # Installation kubeadm, kubelet, kubectl
│   ├── master/               # Initialisation du cluster master
│   ├── worker/               # Jointure des workers
│   └── cni/                  # Installation Flannel/Calico
├── group_vars/
│   ├── all.yml               # Variables globales
│   ├── masters.yml           # Variables spécifiques aux masters
│   └── workers.yml           # Variables spécifiques aux workers
├── inventories/
│   └── terraform_inventory.yml # Généré automatiquement
├── ansible.cfg               # Configuration Ansible
├── generate_inventory.sh     # Script de génération d'inventaire
└── deploy.sh                # Script de déploiement complet
```

## 🚀 Déploiement rapide

### 1. Prérequis
```bash
# Ansible installé
sudo apt update && sudo apt install ansible

# Infrastructure Terraform déployée
cd ../terraform && terraform apply
```

### 2. Déploiement automatique
```bash
# Script tout-en-un
./deploy.sh
```

### 3. Déploiement manuel (étape par étape)
```bash
# Générer l'inventaire depuis Terraform
./generate_inventory.sh

# Tester la connectivité
ansible-playbook playbooks/ping.yml

# Déployer le cluster complet
ansible-playbook playbooks/site.yml
```

## 🎯 Déploiement par étapes

### Phase 1: Préparation
```bash
ansible-playbook playbooks/site.yml --tags preparation
```

### Phase 2: Initialisation master
```bash
ansible-playbook playbooks/site.yml --tags master
```

### Phase 3: Jointure workers
```bash
ansible-playbook playbooks/site.yml --tags worker
```

### Phase 4: CNI
```bash
ansible-playbook playbooks/site.yml --tags cni
```

## ⚙️ Configuration

### Variables principales (group_vars/all.yml)
```yaml
kubernetes_version: "1.28"        # Version K8s
pod_network_cidr: "10.244.0.0/16" # Réseau pods
cni_provider: "flannel"           # CNI (flannel/calico)
```

### Changer le CNI
Pour utiliser Calico au lieu de Flannel :
```yaml
# Dans group_vars/all.yml
cni_provider: "calico"
```

## 🔧 Commandes utiles

### Test de connectivité
```bash
ansible all -m ping
```

### Vérification du cluster
```bash
# Se connecter au master
ssh -i ~/.ssh/id_rsa ubuntu@<MASTER_IP>

# Vérifier les nœuds
kubectl get nodes

# Vérifier les pods système
kubectl get pods -n kube-system
```

### Réinitialisation complète
```bash
ansible-playbook playbooks/reset.yml
```

## 🎛️ Rôles détaillés

### common
- Mise à jour du système
- Désactivation du swap
- Configuration des modules kernel
- Installation et configuration de containerd
- Configuration réseau de base

### kubernetes
- Ajout des repositories Kubernetes
- Installation kubeadm, kubelet, kubectl
- Configuration kubelet
- Verrouillage des versions

### master
- Initialisation du cluster avec kubeadm
- Configuration kubectl pour ubuntu et root
- Génération du token de jointure
- Vérification de l'API server

### worker
- Récupération du token de jointure
- Jointure au cluster
- Vérification du statut kubelet

### cni
- Installation Flannel ou Calico
- Configuration réseau
- Vérification des pods CNI

## 🐛 Dépannage

### Problèmes de connectivité SSH
```bash
# Vérifier les clés SSH
ssh -i ~/.ssh/id_rsa ubuntu@<IP> -v

# Régénérer l'inventaire
./generate_inventory.sh
```

### Problèmes de déploiement
```bash
# Logs détaillés
ansible-playbook playbooks/site.yml -vvv

# Vérifier kubelet
ssh -i ~/.ssh/id_rsa ubuntu@<IP>
sudo journalctl -u kubelet -f
```

### Cluster en erreur
```bash
# Reset et redéploiement
ansible-playbook playbooks/reset.yml
ansible-playbook playbooks/site.yml
```

## 📊 Monitoring

### Vérification du cluster
```bash
# Depuis le master
kubectl get nodes -o wide
kubectl get pods --all-namespaces
kubectl cluster-info

# Statut détaillé
kubectl describe nodes
```

### Logs système
```bash
# Kubelet
sudo journalctl -u kubelet

# Containerd
sudo journalctl -u containerd

# Pods système
kubectl logs -n kube-system <pod-name>
```

## 🔒 Sécurité

### Accès au cluster
Le fichier de configuration kubectl est disponible dans :
- `/etc/kubernetes/admin.conf` (root)
- `/home/ubuntu/.kube/config` (ubuntu)

### Copie locale de la configuration
```bash
# Depuis le master
scp -i ~/.ssh/id_rsa ubuntu@<MASTER_IP>:/home/ubuntu/.kube/config ~/.kube/config

# Modifier l'IP du serveur
kubectl config set-cluster kubernetes --server=https://<MASTER_PUBLIC_IP>:6443
```

## 📈 Prochaines étapes

1. **Ingress Controller** : NGINX, Traefik
2. **Storage** : EBS CSI Driver
3. **Monitoring** : Prometheus, Grafana
4. **Logging** : ELK Stack
5. **CI/CD** : GitLab, Jenkins

## 🤝 Personnalisation

### Ajouter des nœuds
1. Modifier `worker_count` dans Terraform
2. Appliquer : `terraform apply`
3. Régénérer l'inventaire : `./generate_inventory.sh`
4. Déployer les nouveaux nœuds : `ansible-playbook playbooks/site.yml --limit workers`

### Modifier la configuration
1. Éditer les variables dans `group_vars/`
2. Redéployer : `ansible-playbook playbooks/site.yml`

## 📄 Support

- Logs Ansible : Sortie détaillée des playbooks
- Documentation Kubernetes : https://kubernetes.io/docs/
- Issues GitHub : Signaler les problèmes