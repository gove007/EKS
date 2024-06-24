resource "aws_vpc" "eksvpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    "Name"                                              = "${var.project-name}-vpc"
    "kubernetes.io/cluster/${var.project-name}-cluster" = "shared"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.eksvpc.id
  count                   = length(var.public_subnet_cidr)
  cidr_block              = element(var.public_subnet_cidr, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    "Name"                                              = "${var.project-name}-public-subnet"
    "kubernetes.io/cluster/${var.project-name}-cluster" = "shared"
    "kubernetes.io/role/elb"                            = "1"
  })
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.eksvpc.id
  count             = length(var.private_subnet_cidr)
  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, {
    "Name"                                              = "${var.project-name}-private-subnet"
    "kubernetes.io/cluster/${var.project-name}-cluster" = "shared"
    "kubernetes.io/role/internal-elb"                   = "1"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eksvpc.id
  tags = merge(var.common_tags, {
    "Name" = "${var.project-name}-igw"
    }
  )
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.eksvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.common_tags, {
    "Name" = "${var.project-name}-private-rt"
  })
}


resource "aws_route_table_association" "public-rt-association" {
  count          = length(var.public_subnet_cidr)
  route_table_id = aws_route_table.public-rt.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_eip" "nateip" {

  tags = merge(var.common_tags, {
    "name" = "${var.project-name}-eip"
  })
}


resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nateip.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(var.common_tags, {
    "name" = "${var.project-name}-eip"
  })
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.eksvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = merge(var.common_tags, {
    "Name" = "${var.project-name}-public-rt"
  })
}

resource "aws_route_table_association" "private-rt-association" {
  count          = length(var.private_subnet_cidr)
  route_table_id = aws_route_table.private-rt.id
  subnet_id      = aws_subnet.private[count.index].id
  #subnet_id = element(aws_subnet.private[*].id, count.index)
}
