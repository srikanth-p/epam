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