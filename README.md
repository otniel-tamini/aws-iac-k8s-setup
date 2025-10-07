# AWS Infrastructure as Code - Kubernetes Setup

🚀 **Automatisation complète du déploiement d'un cluster Kubernetes sur AWS avec Terraform et Ansible**

## 📋 Description

Ce projet automatise le déploiement d'un cluster Kubernetes sur AWS en utilisant :
- **Terraform** pour l'infrastructure (VPC, EC2, Security Groups, etc.)
- **Ansible** pour la configuration et l'installation de Kubernetes
- **Instances EC2 free-tier** (t2.micro) pour minimiser les coûts

## 🏗️ Architecture

### Infrastructure AWS
- **VPC** dédié avec DNS activé (`10.0.0.0/16`)
- **3 subnets publics** + **1 subnet privé** dans différentes AZ
- **Internet Gateway** + **NAT Gateway** pour la connectivité
- **Security Groups** optimisés pour Kubernetes (tous les ports kubeadm)
- **4 instances EC2** : 1 master + 3 workers

### Ports configurés pour Kubernetes
- **6443** : API Kubernetes
- **2379-2380** : etcd server client API  
- **10250** : Kubelet API
- **10259** : kube-scheduler
- **10257** : kube-controller-manager
- **30000-32767** : NodePort Services
- **8472** : Flannel VXLAN
- **179, 4789** : Calico BGP/VXLAN

## 📁 Structure du projet

```
├── terraform/                 # Infrastructure as Code
│   ├── main.tf                # Configuration principale et VPC
│   ├── variables.tf           # Variables configurables
│   ├── subnets.tf            # Subnets publics et privés
│   ├── gateways.tf           # Internet & NAT Gateways
│   ├── route_tables.tf       # Tables de routage
│   ├── security_groups.tf    # Security Groups Kubernetes
│   ├── ec2_instances.tf      # Instances master et workers
│   ├── outputs.tf            # Outputs pour Ansible
│   ├── terraform.tfvars.example # Exemple de configuration
│   ├── get_ips.sh           # Script pour récupérer les IPs
│   └── README.md            # Documentation Terraform
├── ansible/                  # Configuration & déploiement K8s
└── README.md                # Documentation générale
```

## 🚀 Déploiement rapide

### 1. Prérequis
```bash
# AWS CLI configuré
aws configure

# Terraform installé
terraform --version

# Ansible installé (pour la suite)
ansible --version

# Clé SSH générée
ssh-keygen -t rsa -b 4096
```

### 2. Configuration
```bash
git clone https://github.com/otniel-tamini/aws-iac-k8s-setup.git
cd aws-iac-k8s-setup/terraform

# Configurer les variables
cp terraform.tfvars.example terraform.tfvars
# Modifiez terraform.tfvars selon vos besoins
```

### 3. Déploiement de l'infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 4. Récupération des IPs
```bash
./get_ips.sh
```

## 🎯 Outputs Terraform

Après déploiement, récupérez facilement :
- **IPs publiques/privées** de toutes les instances
- **Commandes SSH** prêtes à utiliser
- **Inventaire Ansible** automatiquement généré
- **Endpoint API Kubernetes**

## 💰 Coûts estimés

| Ressource | Quantité | Coût/mois (USD) |
|-----------|----------|-----------------|
| EC2 t2.micro | 4 instances | ~$34 |
| EBS (20GB) | 4 volumes | ~$8 |
| NAT Gateway | 1 | ~$32 |
| **Total** | | **~$74/mois** |

## 🔒 Sécurité

⚠️ **Configuration par défaut** : Les Security Groups permettent l'accès depuis partout (`0.0.0.0/0`)

**Pour la production** :
- Modifiez `allowed_cidr_blocks` dans `terraform.tfvars`
- Utilisez un bastion host
- Activez VPC Flow Logs
- Configurez CloudTrail

## 🔧 Variables principales

| Variable | Description | Défaut |
|----------|-------------|---------|
| `aws_region` | Région AWS | `us-west-2` |
| `cluster_name` | Nom du cluster | `k8s-cluster` |
| `instance_type` | Type d'instance | `t2.micro` |
| `master_count` | Nombre de masters | `1` |
| `worker_count` | Nombre de workers | `3` |

## 🎮 Commandes utiles

```bash
# Voir toutes les IPs
terraform output all_public_ips

# Connexion SSH rapide
ssh -i ~/.ssh/id_rsa ubuntu@<IP_MASTER>

# Nettoyer l'infrastructure
terraform destroy
```

## 🔄 Prochaines étapes

1. **Configuration Kubernetes** avec Ansible
2. **Installation CNI** (Flannel/Calico)
3. **Déploiement d'applications**
4. **Monitoring et logs**

## 🤝 Contribution

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit vos changements (`git commit -m 'Ajout nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

- 🐛 **Issues** : [GitHub Issues](https://github.com/otniel-tamini/aws-iac-k8s-setup/issues)
- 📧 **Contact** : [Votre email]
- 📖 **Documentation** : Consultez les README dans chaque dossier

---

⭐ **N'oubliez pas de donner une étoile si ce projet vous aide !**