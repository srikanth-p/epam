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
