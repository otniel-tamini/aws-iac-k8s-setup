# Internet Gateway pour l'accès internet depuis les subnets publics
resource "aws_internet_gateway" "kubernetes_igw" {
  vpc_id = aws_vpc.kubernetes_vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-igw"
  })
}

# Elastic IP pour le NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.kubernetes_igw]

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-nat-eip"
  })
}

# NAT Gateway pour l'accès internet depuis les subnets privés
resource "aws_nat_gateway" "kubernetes_nat" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  depends_on    = [aws_internet_gateway.kubernetes_igw]

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-nat-gateway"
  })
}