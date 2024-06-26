provider "aws" {}


resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
     Name = "${var.env_prefix}-igw"
   }
}


resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
     Name = "${var.env_prefix}-rtb"
   }
}

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
}

resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
      from_port = 22
      to_port = 22 
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      # cidr_blocks = [var.my_ip]
    }

    ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 8080
      to_port = 8080
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]

    }

    tags = {
     Name = "${var.env_prefix}-sg"
   }
}






resource "aws_key_pair" "myapp-key" {
  key_name = "myapp-key"
  public_key = "${file(var.public_key_location)}"

  tags = {
    Name = "${var.env_prefix}-key"
  }
}



resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true

  key_name = "myapp-key"

  tags = {
    Name = "${var.env_prefix}-server"
  }


  user_data = file("userdata.sh")
 
}

