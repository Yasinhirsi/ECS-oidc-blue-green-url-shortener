resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

// IAM for ECS task execution and app access to DynamoDB
data "aws_iam_policy_document" "ecs_execution_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecsExecutionRole-url-shortener"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_ecr" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "task_ddb_policy" {
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem"]
    resources = [var.ddb_table_arn]
  }
}

resource "aws_iam_policy" "task_ddb_policy" {
  name   = "url-shortener-ddb-access"
  policy = data.aws_iam_policy_document.task_ddb_policy.json
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "ecsTaskRole-url-shortener"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_assume.json
}

resource "aws_iam_role_policy_attachment" "task_ddb_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.task_ddb_policy.arn
}

// CloudWatch Log Group
resource "aws_cloudwatch_log_group" "cw_log_group" {
  name              = "/ecs/${var.family}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = var.family
      image = var.image
      portMappings = [
        {
          containerPort = var.app_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.cw_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = var.log_stream_prefix
        }
      }
      environment = [
        {
          name  = "TABLE_NAME"
          value = var.table_name
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "${var.family}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.family
    container_port   = var.app_port
  }
}


