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

#Create an RDS Instance and create a DB
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.6.37"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "foo"
  password             = "Bar-1234"
  }

/*Taking snapshot of RDS  
 data "aws_db_snapshot" "db_snapshot" {
    most_recent = true
    db_instance_identifier = "${aws_db_instance.default.identifier}"
}
*/ 