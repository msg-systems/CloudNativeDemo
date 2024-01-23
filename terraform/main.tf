provider "aws" {
  region = var.region
}
data "aws_caller_identity" "current" {}

# ==================================================================
# repositories
# ==================================================================

resource "aws_codecommit_repository" "this" {
  repository_name = var.app_repo_name
  description     = "${var.app_repo_name} Repository"
  default_branch  = "main"
}

resource "aws_ecr_repository" "this" {
  name         = "${var.app_repo_name}_ecr"
  force_delete = true
}

resource "aws_s3_bucket" "this" {
  bucket_prefix = "${var.app_repo_name}-build-artifact"
  force_destroy = true # delete all bucket resources on destroy so bucket can be removed
}

#resource "aws_s3_bucket_acl" "this" {
#  bucket = aws_s3_bucket.this.id
#  acl    = "private"
#}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "bucket_key" {
  description             = "${var.app_repo_name} build_artifact bucket encryption key"
  deletion_window_in_days = 10
}

# ==================================================================
# pipeline
# ==================================================================

# roles

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.app_repo_name}_codepipeline"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codepipeline.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role" "codebuild_role" {
  name = "${var.app_repo_name}_codebuild"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codebuild.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
}


resource "aws_iam_role" "codedeploy_role" {
  name = "${var.app_repo_name}_codedeploy"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codedeploy.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
}

# Policies

resource "aws_iam_role_policy" "codepipeline_policy" {
  role = aws_iam_role.codepipeline_role.name
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "codecommit:CancelUploadArchive",
            "codecommit:GetBranch",
            "codecommit:GetCommit",
            "codecommit:GetRepository",
            "codecommit:GetUploadArchiveStatus",
            "codecommit:UploadArchive"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "codedeploy:CreateDeployment",
            "codedeploy:GetApplication",
            "codedeploy:GetApplicationRevision",
            "codedeploy:GetDeployment",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:RegisterApplicationRevision",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ecs:RegisterTaskDefinition",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "iam:PassRole",
          ]
          Effect   = "Allow"
          Resource = "*"
          Condition = {
            "StringLike" = {
              "iam:PassedToService" = "ecs-tasks.amazonaws.com"
            }
          }
        },
        {
          Action = [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "s3:*"
          ],
          Resource = [
            aws_s3_bucket.this.arn,
            "${aws_s3_bucket.this.arn}/*"
          ],
          Effect = "Allow"
        },
        {
          Action = [
            "kms:DescribeKey",
            "kms:GenerateDataKey*",
            "kms:Encrypt",
            "kms:ReEncrypt*",
            "kms:Decrypt"
          ],
          Resource = aws_kms_key.bucket_key.arn,
          Effect   = "Allow"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.name
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases",
            "codebuild:BatchPutCodeCoverages"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:DescribeImages",
            "ecr:BatchGetImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:PutImage"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ecs:DescribeTaskDefinition"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "s3:*"
          ],
          Resource = [
            aws_s3_bucket.this.arn,
            "${aws_s3_bucket.this.arn}/*"
          ],
          Effect = "Allow"
        },
        {
          Action = [
            "kms:DescribeKey",
            "kms:GenerateDataKey*",
            "kms:Encrypt",
            "kms:ReEncrypt*",
            "kms:Decrypt"
          ],
          Resource = aws_kms_key.bucket_key.arn,
          Effect   = "Allow"
        },
        {
          Effect : "Allow",
          Action : [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeDhcpOptions",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeVpcs"
          ],
          Resource : "*"
        },
        {
          Effect : "Allow",
          Action : [
            "ec2:CreateNetworkInterfacePermission"
          ],
          Resource : [
            "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:network-interface/*"
          ],
          Condition : {
            "StringEquals" : {
              "ec2:Vpc" : data.aws_vpc.default.arn,
              "ec2:AuthorizedService" : "codebuild.amazonaws.com"
            }
          }
        },
      ]
    }
  )
}

resource "aws_iam_role_policy" "codedeploy_policy" {
  role = aws_iam_role.codedeploy_role.name
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "ecs:CreateTaskSet",
            "ecs:DeleteTaskSet",
            "ecs:DescribeServices",
            "ecs:UpdateServicePrimaryTaskSet",
            "elasticloadbalancing:DescribeListeners",
            "elasticloadbalancing:DescribeRules",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:ModifyListener",
            "elasticloadbalancing:ModifyRule"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "s3:GetObject"
          ],
          Resource = [
            "${aws_s3_bucket.this.arn}/*"
          ],
          Effect = "Allow"
        },
        {
          Action = [
            "iam:PassRole",
          ],
          Resource = [
            aws_iam_role.execution_role.arn,
            aws_iam_role.task_role.arn,
          ]
          Effect = "Allow"
        }
      ]
    }
  )
}

# CodeBuild

resource "aws_codebuild_project" "build" {
  name           = "${var.app_repo_name}-build"
  description    = "${var.app_repo_name} Build"
  service_role   = aws_iam_role.codebuild_role.arn
  encryption_key = aws_kms_key.bucket_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.this.bucket}/cache/${var.app_repo_name}"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

    environment_variable {
      name  = "ECR_REPO"
      value = aws_ecr_repository.this.repository_url
    }

    environment_variable {
      name  = "RELEASE_NAME"
      value = var.app_repo_name
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }

    environment_variable {
      name  = "TASK_DEFINITION"
      value = "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:task-definition/${aws_ecs_task_definition.ecs.family}"
    }

    environment_variable {
      name  = "ECS_CAPACITY_PROVIDER"
      value = aws_ecs_capacity_provider.ecs.name
    }

    environment_variable {
      name  = "ECS_CONTAINER_PORT"
      value = var.app_conatiner_port
    }

  }

  source {
    type = "CODEPIPELINE"
  }
}

# CodeDeploy

resource "aws_codedeploy_app" "this" {
  compute_platform = "ECS"
  name             = var.app_repo_name
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = var.app_repo_name
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs.name
    service_name = aws_ecs_service.ecs.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = ["${aws_lb_listener.alb.arn}"]
      }

      target_group {
        name = aws_lb_target_group.alb.*.name[0]
      }

      target_group {
        name = aws_lb_target_group.alb.*.name[1]
      }
    }
  }
}

# CodePipeline

resource "aws_codepipeline" "this" {
  name     = var.app_repo_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.this.bucket
    type     = "S3"
    encryption_key {
      id   = aws_kms_key.bucket_key.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        RepositoryName = aws_codecommit_repository.this.repository_name
        BranchName     = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      category        = "Deploy"
      name            = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["build"]

      configuration = {
        ApplicationName                = aws_codedeploy_app.this.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.this.deployment_group_name
        TaskDefinitionTemplateArtifact = "build"
        AppSpecTemplateArtifact        = "build"
      }
    }
  }
}

# ==================================================================
# rds db
# ==================================================================

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.1"

  identifier = "${var.app_repo_name}-db"

  engine            = "postgres"
  engine_version    = "15.5"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name                = "main"
  username               = "aws_admin"
  create_random_password = true
  random_password_length = 20
  port                   = "5432"

  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = data.aws_subnets.all.ids

  # do not create snapshot on destroy (leads to naming conflicts when repeatedly creating/destroying
  skip_final_snapshot = true

  # DB parameter group
  family = "postgres15"
  # DB option group
  major_engine_version      = "15"
  create_db_option_group    = false
  create_db_parameter_group = true

  parameters = [
    {
      name  = "rds.force_ssl"
      value = "1"
    }
  ]

  backup_retention_period = 0
  deletion_protection     = false
}

resource "aws_security_group" "rds" {
  name   = "${var.app_repo_name}-rds"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "ingress_rds" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "TCP"
  cidr_blocks       = [data.aws_vpc.default.cidr_block]
  security_group_id = aws_security_group.rds.id
}

resource "aws_ssm_parameter" "rdsadmin" {
  name        = "/rds/${var.app_repo_name}/users/admin"
  description = "RDS admin user name"
  type        = "String"
  value       = module.db.db_instance_username
}

resource "aws_ssm_parameter" "rdsadminpassword" {
  name        = "/rds/${var.app_repo_name}/users/admin-password"
  description = "RDS admin user password"
  type        = "SecureString"
  value       = module.db.db_instance_password
}

resource "aws_ssm_parameter" "address" {
  name        = "/rds/${var.app_repo_name}/address"
  description = "RDS address"
  type        = "String"
  value       = module.db.db_instance_address
}

resource "aws_ssm_parameter" "port" {
  name        = "/rds/${var.app_repo_name}/port"
  description = "RDS port"
  type        = "String"
  value       = module.db.db_instance_port
}

resource "aws_ssm_parameter" "name" {
  name        = "/rds/${var.app_repo_name}/name"
  description = "RDS database name"
  type        = "String"
  value       = module.db.db_instance_name
}

# ==================================================================
# ecs cluster
# ==================================================================

# ecs roles

data "aws_iam_policy_document" "ecs_role_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
        "ecs.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ecs_role" {
  name               = "${var.app_repo_name}-ecs"
  assume_role_policy = data.aws_iam_policy_document.ecs_role_assume.json
}

data "aws_iam_policy_document" "ecs_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecs:StartTask"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ecs_policy" {
  name   = "${var.app_repo_name}-ecs"
  policy = data.aws_iam_policy_document.ecs_policy_document.json
}

resource "aws_iam_role_policy_attachment" "ecs" {
  policy_arn = aws_iam_policy.ecs_policy.arn
  role       = aws_iam_role.ecs_role.name
}

data "aws_iam_policy_document" "assume_by_ecs" {
  statement {
    sid     = "AllowAssumeByEcsTasks"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "execution_role" {
  statement {
    sid    = "AllowECRPull"
    effect = "Allow"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]

    resources = [aws_ecr_repository.this.arn]
  }

  statement {
    sid    = "AllowECRAuth"
    effect = "Allow"

    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudwatch"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowSSMParameterAccess"
    effect = "Allow"

    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "kms:Decrypt"
    ]

    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/rds/${var.app_repo_name}/*",
      "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:alias/aws/ssm"
    ]
  }
}

data "aws_iam_policy_document" "task_role" {
  statement {
    sid    = "AllowDescribeCluster"
    effect = "Allow"

    actions = ["ecs:DescribeClusters"]

    resources = [aws_ecs_cluster.ecs.arn]
  }
}

resource "aws_iam_role" "execution_role" {
  name               = "${var.app_repo_name}-ecs-execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
}

resource "aws_iam_role_policy" "execution_role" {
  role   = aws_iam_role.execution_role.name
  policy = data.aws_iam_policy_document.execution_role.json
}

resource "aws_iam_role" "task_role" {
  name               = "${var.app_repo_name}-ecs-task_role"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
}

resource "aws_iam_role_policy" "task_role" {
  role   = aws_iam_role.task_role.name
  policy = data.aws_iam_policy_document.task_role.json
}

# EC2 ASG

data "aws_ami" "amazonlinux" {
  most_recent = "true"
  owners      = ["amazon"]
  name_regex  = "^amzn2-ami-ecs-hvm-2.*-ebs"
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${var.app_repo_name}-ecs"
  role = aws_iam_role.ecs_role.name
}

resource "aws_security_group" "ecs" {
  name   = "${var.app_repo_name}-ecs"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Application"
    from_port       = var.app_conatiner_port
    to_port         = var.app_conatiner_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_ecs_cluster" "ecs" {
  name = "${var.app_repo_name}-ecs"
}

resource "aws_autoscaling_group" "ecs-cluster" {
  name              = "${var.app_repo_name}-ecs"
  min_size          = "1"
  max_size          = "2"
  health_check_type = "EC2"
  launch_template {
    id      = aws_launch_template.ecs.id
    version = aws_launch_template.ecs.latest_version
  }
  vpc_zone_identifier = data.aws_subnets.all.ids

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "ecs" {
  name = "${var.app_repo_name}-ecs"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs-cluster.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs" {
  cluster_name = aws_ecs_cluster.ecs.name

  capacity_providers = [aws_ecs_capacity_provider.ecs.name]
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs.name
    weight            = 100
  }
}

resource "aws_launch_template" "ecs" {
  name          = "${var.app_repo_name}-ecs"
  image_id      = data.aws_ami.amazonlinux.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.ecs.id}"]
  }

  user_data = base64encode("#!/bin/bash\necho ECS_CLUSTER='${var.app_repo_name}-ecs' > /etc/ecs/ecs.config")
}

resource "aws_ecs_service" "ecs" {
  name            = "${var.app_repo_name}-ecs"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:task-definition/${aws_ecs_task_definition.ecs.family}"

  desired_count = 1

  tags           = {}
  propagate_tags = "NONE"

  load_balancer {
    target_group_arn = aws_lb_target_group.alb[0].arn
    container_name   = var.app_repo_name
    container_port   = var.app_conatiner_port
  }
  health_check_grace_period_seconds = 60

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets         = data.aws_subnets.all.ids
    security_groups = [aws_security_group.ecs.id]
  }
  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer,
      capacity_provider_strategy
    ]
  }

}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/ecs/service/${var.app_repo_name}"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "ecs" {
  family = "${var.app_repo_name}-ecs"
  container_definitions = jsonencode([
    {
      name      = var.app_repo_name
      image     = "${aws_ecr_repository.this.repository_url}:latest"
      cpu       = 1
      memory    = 768
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.app_conatiner_port
          hostPort      = var.app_conatiner_port
        }
      ]
      environment : [
        {
          name  = "SPRING_PROFILES_ACTIVE",
          value = "ecs"
        },
        {
          name  = "SERVER_PORT"
          value = tostring(var.app_conatiner_port)
        }
      ]
      secrets : [
        {
          name      = "SECRET_DB_HOST",
          valueFrom = aws_ssm_parameter.address.arn
        },
        {
          name      = "SECRET_DB_PORT",
          valueFrom = aws_ssm_parameter.port.arn
        },
        {
          name      = "SECRET_DB_NAME",
          valueFrom = aws_ssm_parameter.name.arn
        },
        {
          name      = "SECRET_DB_USERNAME",
          valueFrom = aws_ssm_parameter.rdsadmin.arn
        },
        {
          name      = "SECRET_DB_PASSWORD",
          valueFrom = aws_ssm_parameter.rdsadminpassword.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.logs.name}"
          awslogs-region        = "${var.region}"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  execution_role_arn = aws_iam_role.execution_role.arn
  task_role_arn      = aws_iam_role.task_role.arn
  network_mode       = "awsvpc"
}

# alb

resource "aws_security_group" "alb" {
  name   = "${var.app_repo_name}-alb"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name               = "${var.app_repo_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.all.ids
}

locals {
  target_groups = [
    "green",
    "blue",
  ]
}

resource "aws_lb_target_group" "alb" {
  count = length(local.target_groups)

  name = "${var.app_repo_name}-${element(local.target_groups, count.index)}"

  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path = "/"
    port = var.app_conatiner_port
  }
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.*.arn[0]
  }

  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}

resource "aws_lb_listener_rule" "alb" {
  listener_arn = aws_lb_listener.alb.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.*.arn[0]
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  lifecycle {
    ignore_changes = [
      action
    ]
  }
}
