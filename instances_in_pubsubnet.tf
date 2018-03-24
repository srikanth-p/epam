provider "aws" {
    access_key = "AKIAI3LNHDRVI6XNAZGQ"
    secret_key = "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"
}

/* The VPC that spans across multiple availability zones.

 Given the CIDR 10.0.0.0/16, we can have IPs from 10.0.0.1
 up to 10.0.255.254. Essentially we can host 65k IPs in
 that range.*/
 
resource "aws_vpc" "epam" {
  cidr_block = "10.0.0.0/16"
	tags {
	Name = "aws_vpc"}
}

#Create Public Subnet 
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = "${aws_vpc.epam.id}"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags {
    Name = "blog"
  }
}

#Create a security group
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  vpc_id = "${aws_vpc.epam.id}"
    ingress {
    from_port = "${var.server_port}"
	to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create 2 Instances in public subnet
resource "aws_instance" "pubinstance" {
  count			= 2
  ami           = "ami-66506c1c"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.public_subnet_a.id}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  tags {
        Name = "pubinstance"
  }
}
