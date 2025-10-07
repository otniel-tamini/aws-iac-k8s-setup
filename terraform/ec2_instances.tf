# Data source pour récupérer la dernière AMI Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Paire de clés SSH
resource "aws_key_pair" "kubernetes_key" {
  key_name   = var.key_pair_name
  public_key = file("~/.ssh/id_rsa.pub") # Modifiez le chemin selon vos besoins
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-key-pair"
  })
}

# Instances EC2 pour les nœuds master
resource "aws_instance" "kubernetes_master" {
  count = var.master_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.master_instance_type
  key_name              = aws_key_pair.kubernetes_key.key_name
  vpc_security_group_ids = [aws_security_group.kubernetes_master_sg.id]
  subnet_id             = aws_subnet.public_subnets[count.index % length(aws_subnet.public_subnets)].id
  
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
    encrypted   = true
    
    tags = merge(local.common_tags, {
      Name = "${local.cluster_name}-master-${count.index + 1}-root"
    })
  }



  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-master-${count.index + 1}"
    Type = "Master"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Instances EC2 pour les nœuds worker
resource "aws_instance" "kubernetes_worker" {
  count = var.worker_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.worker_instance_type
  key_name              = aws_key_pair.kubernetes_key.key_name
  vpc_security_group_ids = [aws_security_group.kubernetes_worker_sg.id]
  subnet_id             = aws_subnet.public_subnets[count.index % length(aws_subnet.public_subnets)].id
  
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
    
    tags = merge(local.common_tags, {
      Name = "${local.cluster_name}-worker-${count.index + 1}-root"
    })
  }



  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-worker-${count.index + 1}"
    Type = "Worker"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  })

  depends_on = [aws_instance.kubernetes_master]

  lifecycle {
    create_before_destroy = true
  }
}