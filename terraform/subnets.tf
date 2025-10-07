# Subnets publics pour les nœuds Kubernetes
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)
  
  vpc_id                  = aws_vpc.kubernetes_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-public-subnet-${count.index + 1}"
    Type = "Public"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "kubernetes.io/role/elb" = "1"
  })
}

# Subnet privé pour les ressources internes
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  
  vpc_id            = aws_vpc.kubernetes_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-private-subnet-${count.index + 1}"
    Type = "Private"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb" = "1"
  })
}