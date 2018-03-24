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

#Create Private Subnet
resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = "${aws_vpc.epam.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"

  tags {
    Name = "blog"
  }
}
