# 1. Create a Dedicated Custom VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "swiggy-vpc" }
}

# 2. Create a Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags = { Name = "swiggy-public-subnet" }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "swiggy-igw" }
}

# 4. Custom Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# 5. Associate Route Table to Subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

# 6. Security Group in the NEW VPC
resource "aws_security_group" "project-sg" {
  name   = "project-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 7. EC2 Instance in the NEW VPC with Increased Storage
resource "aws_instance" "web" {
  ami                    = "ami-0dee22c13ea7a9a67"
  instance_type          = "t3.large"     # upgraded"
  key_name                = "project"
  vpc_security_group_ids = [aws_security_group.project-sg.id]
  subnet_id              = aws_subnet.public.id

  # THIS SECTION INCREASES YOUR DISK SPACE
  root_block_device {
    volume_size = 26    # Set to 26 for safe practice
    volume_type = "gp3" # Faster and cheaper than gp2
  }

  tags = { Name = "Swiggy-Project-Server" }

  user_data = file("install.sh")
}
