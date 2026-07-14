resource "aws_vpc" "devops_trainer_vpc"{
    cidr_block = "10.0.0.0/20"
}

resource "aws_subnet" "devops_trainer_subnet"{
    vpc_id = aws_vpc.devops_trainer_vpc.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true
    availability_zone = "eu-west-3a"
}

resource "aws_subnet" "devops_trainer_subnet2" {
  vpc_id                  = aws_vpc.devops_trainer_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-3b"
}

resource "aws_internet_gateway" "devops_trainer_igw"{
    vpc_id = aws_vpc.devops_trainer_vpc.id
}

resource "aws_route_table" "devops_trainer_rt"{
    vpc_id = aws_vpc.devops_trainer_vpc.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.devops_trainer_igw.id
    }
}

resource "aws_route_table_association" "devops_trainer_rta" {
  subnet_id      = aws_subnet.devops_trainer_subnet.id
  route_table_id = aws_route_table.devops_trainer_rt.id
}

resource "aws_route_table_association" "devops_trainer_rta_sn2"{
    subnet_id = aws_subnet.devops_trainer_subnet2.id
    route_table_id = aws_route_table.devops_trainer_rt.id
}