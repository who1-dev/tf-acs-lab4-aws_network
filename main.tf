# Step 1 - Define the provider
provider "aws" {
  region = var.region
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  default_tags = merge(var.default_tags, { "ENV" : upper(var.env) })
  name_prefix  = upper("${var.namespace}-${var.env}")
}

# Create a new VPC 
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-VPC"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-IGW"
    }
  )
}

# Add provisioning of the public subnetin the default VPC
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-PUBLIC-SUBNET"
    }
  )
}


# Route table to route add default gateway pointing to Internet Gateway (IGW)
resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${local.name_prefix}-PUBLIC-ROUTE-TABLE"
  }
}

# Associate subnets with the custom route table
resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_subnet_route_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}