provider "aws" {
  region = "eu-west-3"
}

variable "db_password" {
  description = "Mot de passe RDS"
  sensitive   = true
}

variable "my_ip" {
  description = "Adresse IP autorisée en SSH (format CIDR, ex: 1.2.3.4/32)"
  type        = string
}

resource "aws_instance" "devops_trainer_ec2" {
  ami                    = "ami-0be40a46b4111e7f5"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.devops_trainer_sg.id]
  key_name               = aws_key_pair.devops_trainer_key.key_name
  iam_instance_profile   = "ec2-s3-role"
  subnet_id              = aws_subnet.devops_trainer_subnet.id

  tags = {
    Name = "devops_trainer_tf"
  }
}

resource "aws_db_instance" "devops_trainer_instance" {
  engine = "mariadb"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  db_name = "devops_trainer"
  username = "admin"
  password =  var.db_password 
  db_subnet_group_name   = aws_db_subnet_group.devops_trainer_subnet_group.name
  vpc_security_group_ids = [aws_security_group.devops_trainer_rds_sg.id]
  skip_final_snapshot    = true
}

resource "aws_security_group" "devops_trainer_sg" {
  name   = "devops-trainer-sg"
  vpc_id = aws_vpc.devops_trainer_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
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
resource "aws_security_group" "devops_trainer_rds_sg" {
  name = "devops-trainer-rds-sg"
  vpc_id = aws_vpc.devops_trainer_vpc.id 

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.devops_trainer_sg.id]
  } 
}
  
resource "aws_key_pair" "devops_trainer_key" {
  key_name   = "cle-terraform-florian"
  public_key = file("~/.ssh/cle-florian.pub")
}

output "ec2_public_ip" {
  value = aws_eip.devops_trainer_eip.public_ip
}

resource "local_file" "ansible_inventory" {
  content  = "[ec2]\n${aws_eip.devops_trainer_eip.public_ip} ansible_ssh_private_key_file=~/.ssh/cle-florian.pem\n"
  filename = "../ansible/inventory.ini"
}

resource "aws_vpc" "devops_trainer_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_db_subnet_group" "devops_trainer_subnet_group" {
  name       = "devops-trainer-subnet-group"
  subnet_ids = [aws_subnet.devops_trainer_subnet.id, aws_subnet.devops_trainer_subnet2.id]
}

resource "aws_subnet" "devops_trainer_subnet" {
  vpc_id                  = aws_vpc.devops_trainer_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-3a"
}

resource "aws_subnet" "devops_trainer_subnet2" {
  vpc_id                  = aws_vpc.devops_trainer_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-3b"
}

resource "aws_internet_gateway" "devops_trainer_igw" {
  vpc_id = aws_vpc.devops_trainer_vpc.id
}

resource "aws_route_table" "devops_trainer_rt" {
  vpc_id = aws_vpc.devops_trainer_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_trainer_igw.id
  }
}

resource "aws_route_table_association" "devops_trainer_rta" {
  subnet_id      = aws_subnet.devops_trainer_subnet.id
  route_table_id = aws_route_table.devops_trainer_rt.id
}

resource "aws_eip" "devops_trainer_eip" {
  instance = aws_instance.devops_trainer_ec2.id
  domain   = "vpc"
}
