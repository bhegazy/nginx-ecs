resource "aws_iam_role" "ecs" {
  name = "${var.name}-ecs-role"

  assume_role_policy = <<EOF
{
 "Version": "2008-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": [
         "ecs.amazonaws.com",
         "ec2.amazonaws.com"
       ]
     },
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy" "ecs-instance" {
  name = "${var.name}-ecs-instance-role-policy"
  role = "${aws_iam_role.ecs.id}"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "ecs:CreateCluster",
       "ecs:DeregisterContainerInstance",
       "ecs:DeregisterTaskDefinition",
       "ecs:DescribeServices",
       "ecs:DescribeTaskDefinition",
       "ecs:DescribeTasks",
       "ecs:DiscoverPollEndpoint",
       "ecs:Poll",
       "ecs:RegisterContainerInstance",
       "ecs:RegisterTaskDefinition",
       "ecs:StartTelemetrySession",
       "ecs:Submit*",
       "ecs:StartTask",
       "ecs:StopTask",
       "ecs:ListTasks",
       "ecs:ListTaskDefinitions",
       "ecs:UpdateService",
       "ecr:GetAuthorizationToken",
       "ecr:BatchCheckLayerAvailability",
       "ecr:GetDownloadUrlForLayer",
       "ecr:BatchGetImage",
       "logs:CreateLogStream",
       "logs:PutLogEvents",
       "iam:PassRole"
     ],
     "Resource": "*"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy" "ecs-service" {
  name = "${var.name}-ecs-service-role-policy"
  role = "${aws_iam_role.ecs.id}"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "ec2:AuthorizeSecurityGroupIngress",
               "ec2:Describe*",
               "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
               "elasticloadbalancing:Describe*",
               "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
               "elasticloadbalancing:DeregisterTargets",
               "elasticloadbalancing:DescribeTargetGroups",
               "elasticloadbalancing:DescribeTargetHealth",
               "elasticloadbalancing:RegisterTargets"
           ],
           "Resource": "*"
       }
   ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${var.name}-ecs-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs.name}"
}
