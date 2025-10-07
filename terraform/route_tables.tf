# Table de routage pour les subnets publics
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.kubernetes_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubernetes_igw.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-public-rt"
    Type = "Public"
  })
}

# Association des subnets publics avec la table de routage publique
resource "aws_route_table_association" "public_subnet_associations" {
  count = length(aws_subnet.public_subnets)
  
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Table de routage pour les subnets privés
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.kubernetes_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.kubernetes_nat.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-private-rt"
    Type = "Private"
  })
}

# Association des subnets privés avec la table de routage privée
resource "aws_route_table_association" "private_subnet_associations" {
  count = length(aws_subnet.private_subnets)
  
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}