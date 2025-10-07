# Infrastructure Terraform pour Cluster Kubernetes sur AWS

Ce projet Terraform déploie l'infrastructure nécessaire pour un cluster Kubernetes sur AWS en utilisant des instances EC2 free-tier.

## Architecture

- **VPC** : Un VPC dédié avec DNS activé
- **Subnets** : 3 subnets publics et 1 subnet privé dans différentes AZ
- **Gateways** : Internet Gateway pour les subnets publics et NAT Gateway pour le privé
- **Security Groups** : Groupes de sécurité optimisés pour kubeadm avec tous les ports nécessaires
- **EC2 Instances** : Instances t2.micro/t3.micro pour les nœuds master et worker

## Ports ouverts pour Kubernetes

### Nœuds Master
- **6443** : API Kubernetes
- **2379-2380** : etcd server client API
- **10250** : Kubelet API
- **10259** : kube-scheduler
- **10257** : kube-controller-manager
- **30000-32767** : NodePort Services

### Nœuds Worker
- **10250** : Kubelet API
- **30000-32767** : NodePort Services

### CNI (Flannel/Calico)
- **8472** : Flannel VXLAN
- **179** : Calico BGP
- **4789** : Calico VXLAN

## Prérequis

1. **AWS CLI** configuré avec les bonnes permissions
2. **Terraform** installé (version >= 1.0)
3. **Clé SSH** générée (`ssh-keygen -t rsa -b 4096`)

## Installation

1. **Cloner le repository**
   ```bash
   git clone <repo-url>
   cd terraform-ansible-automation-on-aws/terraform
   ```

2. **Configurer les variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Modifiez terraform.tfvars selon vos besoins
   ```

3. **Initialiser Terraform**
   ```bash
   terraform init
   ```

4. **Planifier le déploiement**
   ```bash
   terraform plan
   ```

5. **Déployer l'infrastructure**
   ```bash
   terraform apply
   ```

## Configuration des variables

| Variable | Description | Défaut |
|----------|-------------|---------|
| `aws_region` | Région AWS | `us-west-2` |
| `cluster_name` | Nom du cluster | `k8s-cluster` |
| `instance_type` | Type d'instance EC2 | `t2.micro` |
| `master_count` | Nombre de masters | `1` |
| `worker_count` | Nombre de workers | `2` |
| `key_pair_name` | Nom de la clé SSH | `kubernetes-key` |

## Outputs

Après le déploiement, Terraform affichera :
- IDs des ressources créées
- Adresses IP publiques et privées des instances
- Commandes SSH pour se connecter
- Informations pour l'inventaire Ansible

## Utilisation avec Ansible

Les outputs Terraform incluent les informations nécessaires pour générer automatiquement l'inventaire Ansible :

```bash
# Récupérer les informations d'inventaire
terraform output ansible_inventory
```

## Coûts estimés

- **Instances EC2** : ~$8.5/mois par instance t2.micro
- **Stockage EBS** : ~$2/mois par instance (20GB)
- **NAT Gateway** : ~$32/mois
- **Total pour 3 instances** : ~$65/mois

## Nettoyage

Pour supprimer toute l'infrastructure :

```bash
terraform destroy
```

## Sécurité

⚠️ **Important** : Par défaut, les security groups permettent l'accès depuis n'importe où (`0.0.0.0/0`). En production :

1. Modifiez `allowed_cidr_blocks` pour restreindre l'accès SSH
2. Utilisez un bastion host pour l'accès aux instances
3. Activez VPC Flow Logs pour le monitoring
4. Configurez AWS CloudTrail pour l'audit

## Prochaines étapes

1. Utilisez Ansible pour configurer et installer Kubernetes sur les instances
2. Configurez un CNI (Flannel, Calico, ou Weave)
3. Déployez vos applications Kubernetes

## Support

Ce template est optimisé pour :
- Ubuntu 22.04 LTS
- Kubernetes v1.28
- Free tier AWS (t2.micro instances)
- kubeadm pour l'installation du cluster