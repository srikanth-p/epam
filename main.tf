provider "aws" {
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

#Create 2 Instances in private subnet
resource "aws_instance" "priinstance" {
  count			= 2
  ami           = "ami-66506c1c"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.private_subnet_a.id}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  tags {
        Name = "priinstance"
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

#CodeDeploy IAM Roles and CodeDeploy App/Group
resource "aws_iam_role" "codedeploy_role_name" {
  name = "codedeploy_role_name"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "codedeploy.amazonaws.com",
            "ec2.amazonaws.com"
          ]
        },
        "Action": "sts:AssumeRole"
      }
    ]
}
EOF
}

resource "aws_codedeploy_app" "analytics_app" {
  name = "analytics_app"
}

resource "aws_codedeploy_deployment_config" "analytics_deployment_config" {
  deployment_config_name = "analytics_deployment_config"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 2
  }
}

resource "aws_codedeploy_deployment_group" "analytics_group" {
  app_name              = "${aws_codedeploy_app.analytics_app.name}"
  deployment_group_name = "analytics_group"
  service_role_arn      = "${aws_iam_role.codedeploy_role_name.arn}"
  deployment_config_name = "analytics_deployment_config"

  ec2_tag_filter {
    key   = "CodeDeploy"
    type  = "KEY_AND_VALUE"
    value = "analytics"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

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

#IAM Policy to give read only access to s3 bucket
resource "aws_iam_user_policy" "test_user_ro" {
    name = "testbucketterraform"
    policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
				"s3:Get*",
				"s3:List*"
				]
            "Resource": "*"
        }
   ]
}
EOF
}
