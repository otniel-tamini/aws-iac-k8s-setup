# AWS Infrastructure as Code - Kubernetes Cluster Setup

🚀 **Fully automated Kubernetes cluster deployment on AWS using Terraform and Ansible**

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-2.9+-EE0000?logo=ansible)](https://www.ansible.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)

## 📋 Overview

This project demonstrates DevOps best practices by automating the complete lifecycle of a Kubernetes cluster on AWS. It showcases skills in:

- **Infrastructure as Code (IaC)** - Terraform for AWS resource provisioning
- **Configuration Management** - Ansible for automated Kubernetes deployment
- **Container Orchestration** - Production-ready Kubernetes cluster with kubeadm
- **Cloud Networking** - VPC design, subnets, security groups, and routing
- **Automation** - End-to-end deployment with a single command

This project is ideal for DevOps portfolios, demonstrating expertise in cloud infrastructure, automation, and Kubernetes.

## ✨ Key Features

- 🏗️ **Complete AWS Infrastructure** - VPC, multi-AZ subnets, gateways, security groups, EC2 instances
- 🤖 **Full Automation** - One-command deployment from infrastructure to running cluster
- 🔒 **Security Configured** - Properly configured security groups for all Kubernetes components
-  **Production-Ready Patterns** - Multi-AZ deployment, encrypted volumes, HA-ready architecture
- 🔄 **Idempotent Playbooks** - Ansible roles can be executed multiple times safely
- 📝 **Clean Code** - Well-structured, modular, and documented IaC templates

## 🏗️ Architecture

### AWS Infrastructure

```
┌─────────────────────────────────────────────────────────────┐
│                    VPC (10.0.0.0/16)                        │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │Public Subnet │  │Public Subnet │  │Public Subnet │      │
│  │  10.0.1.0/24 │  │  10.0.2.0/24 │  │  10.0.3.0/24 │      │
│  │   (AZ-A)     │  │   (AZ-B)     │  │   (AZ-C)     │      │
│  │              │  │              │  │              │      │
│  │  🖥️ Master   │  │  🖥️ Worker-1 │  │  🖥️ Worker-2 │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                              │
│  ┌──────────────┐                                           │
│  │Private Subnet│                                           │
│  │ 10.0.10.0/24 │  (Reserved for future use)               │
│  │   (AZ-A)     │                                           │
│  └──────────────┘                                           │
│                                                              │
│  🌐 Internet Gateway    🔒 NAT Gateway                      │
└─────────────────────────────────────────────────────────────┘
```

### Kubernetes Components

- **Control Plane**: API Server, etcd, Controller Manager, Scheduler
- **Worker Nodes**: 3 nodes running kubelet, kube-proxy, container runtime
- **Container Runtime**: containerd (configured with systemd cgroup driver)
- **CNI**: Flannel (VXLAN mode) - Calico available as alternative

### Network Ports

| Port Range | Protocol | Purpose |
|------------|----------|---------|
| 6443 | TCP | Kubernetes API Server |
| 2379-2380 | TCP | etcd server client API |
| 10250 | TCP | Kubelet API |
| 10257 | TCP | kube-controller-manager |
| 10259 | TCP | kube-scheduler |
| 30000-32767 | TCP | NodePort Services |
| 8472 | UDP | Flannel VXLAN |
| 179 | TCP | Calico BGP (optional) |
| 4789 | UDP | Calico VXLAN (optional) |

## 📁 Project Structure

```
aws-iac-k8s-setup/
├── terraform/                      # Infrastructure as Code
│   ├── main.tf                     # Provider and VPC configuration
│   ├── variables.tf                # Input variables
│   ├── subnets.tf                  # Public and private subnets
│   ├── gateways.tf                 # Internet & NAT gateways
│   ├── route_tables.tf             # Route tables and associations
│   ├── security_groups.tf          # Security groups for K8s
│   ├── ec2_instances.tf            # Master and worker instances
│   ├── outputs.tf                  # Output values
│   ├── get_ips.sh                  # Helper script to get IPs
│   └── README.md                   # Terraform documentation
│
├── ansible/                        # Configuration management
│   ├── playbooks/
│   │   ├── site.yml                # Main deployment playbook
│   │   ├── ping.yml                # Connectivity test
│   │   └── reset.yml               # Cluster reset playbook
│   ├── roles/
│   │   ├── common/                 # Base system configuration
│   │   ├── kubernetes/             # Kubernetes packages
│   │   ├── master/                 # Control plane setup
│   │   ├── worker/                 # Worker node configuration
│   │   └── cni/                    # Network plugin installation
│   ├── inventories/
│   │   └── terraform_inventory.yml # Dynamic inventory
│   └── ansible.cfg                 # Ansible configuration
│
├── .gitignore                      # Git ignore rules
└── README.md                       # This file
```

## 🚀 How to Use

### Prerequisites

Before starting, ensure you have:

- **AWS Account** with administrative access
- **AWS CLI** installed and configured
  ```bash
  aws configure
  ```
- **Terraform** >= 1.0 ([Download](https://www.terraform.io/downloads))
- **Ansible** >= 2.9 ([Installation guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html))
- **SSH Key Pair** generated at `~/.ssh/id_rsa`
- **Python 3** with `netaddr` library
  ```bash
  pip3 install netaddr boto3
  ```

### Quick Start

**1. Clone the repository**
```bash
git clone https://github.com/otniel-tamini/aws-iac-k8s-setup.git
cd aws-iac-k8s-setup
```

**2. Deploy the infrastructure with Terraform**
```bash
cd terraform

# Initialize Terraform (downloads providers)
terraform init

# Preview the infrastructure changes
terraform plan

# Create the infrastructure
terraform apply
```

This creates all AWS resources: VPC, subnets, gateways, security groups, and 4 EC2 instances (1 master + 3 workers).

**3. Deploy Kubernetes with Ansible**
```bash
cd ../ansible

# Verify connectivity to all nodes
ansible-playbook playbooks/ping.yml

# Deploy the complete Kubernetes cluster
ansible-playbook playbooks/site.yml
```

This automatically:
- Configures system requirements (kernel modules, sysctl parameters)
- Installs and configures containerd
- Installs Kubernetes packages (kubeadm, kubelet, kubectl)
- Initializes the cluster on the master node
- Joins worker nodes to the cluster
- Installs Flannel CNI for pod networking

**4. Verify the cluster**
```bash
# Get the master node IP
cd ../terraform
terraform output master_public_ips

# SSH to the master node
ssh ubuntu@<MASTER_IP>

# Check cluster status
kubectl get nodes
kubectl get pods -A
```

Expected output:
```
NAME                   STATUS   ROLES           AGE   VERSION
k8s-cluster-master-1   Ready    control-plane   5m    v1.28.15
k8s-cluster-worker-1   Ready    <none>          4m    v1.28.15
k8s-cluster-worker-2   Ready    <none>          4m    v1.28.15
k8s-cluster-worker-3   Ready    <none>          4m    v1.28.15
```

**5. Deploy a test application**
```bash
# Create a deployment
kubectl create deployment nginx --image=nginx

# Expose it via NodePort
kubectl expose deployment nginx --port=80 --type=NodePort

# Get the service details
kubectl get svc nginx

# Access the application
curl http://<WORKER_IP>:<NODE_PORT>
```

**6. Clean up resources**
```bash
# Destroy all AWS resources to avoid charges
cd terraform
terraform destroy
```

## 🔧 Customization

### Terraform Variables

Customize your deployment by editing `terraform/variables.tf` or creating a `terraform.tfvars` file:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | `us-west-2` |
| `cluster_name` | Kubernetes cluster name | `k8s-cluster` |
| `master_instance_type` | EC2 type for master node | `t3.small` |
| `worker_instance_type` | EC2 type for worker nodes | `t3.micro` |
| `master_count` | Number of master nodes | `1` |
| `worker_count` | Number of worker nodes | `3` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |

Example `terraform.tfvars`:
```hcl
aws_region            = "eu-west-2"
cluster_name          = "my-k8s-cluster"
worker_count          = 5
master_instance_type  = "t3.medium"
worker_instance_type  = "t3.small"
```

### Ansible Variables

Modify cluster configuration in `ansible/group_vars/all.yml`:

| Variable | Description | Default |
|----------|-------------|---------|
| `kubernetes_version` | Kubernetes version to install | `1.28` |
| `cni_provider` | Network plugin (flannel/calico) | `flannel` |
| `pod_network_cidr` | Pod network CIDR | `10.244.0.0/16` |
| `service_cidr` | Service network CIDR | `10.96.0.0/12` |

## � Contact

- 🐛 **Report Issues**: [GitHub Issues](https://github.com/otniel-tamini/aws-iac-k8s-setup/issues)
- 💬 **Questions**: [GitHub Discussions](https://github.com/otniel-tamini/aws-iac-k8s-setup/discussions)

## � Acknowledgments

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Flannel CNI](https://github.com/flannel-io/flannel)

---

<div align="center">

**Made with ❤️ for learning DevOps and Cloud Infrastructure**

⭐ Star this repository if you found it helpful!

</div>

## 🎮 Useful Commands

### Terraform Operations
```bash
# View all outputs
terraform output

# Get specific output (e.g., master IPs)
terraform output master_public_ips

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Destroy infrastructure
terraform destroy
```

### Ansible Operations
```bash
# Test connectivity
ansible-playbook playbooks/ping.yml

# Deploy complete cluster
ansible-playbook playbooks/site.yml

# Run specific role
ansible-playbook playbooks/site.yml --tags common

# Run on specific hosts
ansible-playbook playbooks/site.yml --limit masters

# Dry run (check mode)
ansible-playbook playbooks/site.yml --check

# Reset cluster (removes all Kubernetes components)
ansible-playbook playbooks/reset.yml
```

### Kubernetes Operations
```bash
# View cluster information
kubectl cluster-info

# Get all resources across all namespaces
kubectl get all -A

# Check node status and resource usage
kubectl get nodes -o wide
kubectl top nodes

# View system pods
kubectl get pods -n kube-system

# Scale a deployment
kubectl scale deployment nginx --replicas=5
```

## 🧪 Testing Your Deployment

### 1. Connectivity Test
```bash
cd ansible
ansible-playbook playbooks/ping.yml
```

### 2. Deploy Sample Application
```bash
# SSH to master node
ssh ubuntu@<MASTER_IP>

# Create nginx deployment
kubectl create deployment nginx --image=nginx:alpine --replicas=3

# Expose via NodePort
kubectl expose deployment nginx --port=80 --type=NodePort

# Get service details
kubectl get svc nginx

# Test access (use any worker node IP)
curl http://<WORKER_IP>:<NODE_PORT>
```

### 3. Verify Cluster Health
```bash
# Check node status
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system

# Check Flannel CNI
kubectl get pods -n kube-flannel

# View cluster events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

## 🔄 Maintenance

### Updating Kubernetes
1. Update `kubernetes_version` in Ansible variables
2. Run Ansible playbook
3. Upgrade nodes one by one

### Scaling Workers
```bash
# In terraform/terraform.tfvars
worker_count = 5

# Apply changes
terraform apply

# Join new nodes
cd ../ansible
ansible-playbook playbooks/site.yml --tags worker
```

## � Troubleshooting

### Common Issues

**Issue**: Nodes in `NotReady` state
```bash
# Check CNI pods
kubectl get pods -n kube-flannel
kubectl logs -n kube-flannel <pod-name>
```

**Issue**: containerd not running
```bash
# SSH to node
systemctl status containerd
journalctl -u containerd -f
```

**Issue**: Terraform authentication error
```bash
# Reconfigure AWS CLI
aws configure
```

## 🙏 Acknowledgments

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Flannel CNI](https://github.com/flannel-io/flannel)

## 📞 Support

- 🐛 **Report Issues**: [GitHub Issues](https://github.com/otniel-tamini/aws-iac-k8s-setup/issues)
- � **Discussions**: [GitHub Discussions](https://github.com/otniel-tamini/aws-iac-k8s-setup/discussions)
- 📧 **Email**: [otnieltamini@gmail.com](mailto:otnieltamini@gmail.com)

<div align="center">

⭐ **If this project helped you, please give it a star!** ⭐

Made with ❤️ by [Otniel Tamini](https://github.com/otniel-tamini)

</div>