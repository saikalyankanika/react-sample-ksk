resource "aws_ecs_cluster" "this" {
  name = "ecs-${var.project_name}-${var.app_name}"

  tags = {
    Name = "ecs-${var.project_name}-${var.app_name}"
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_ecs_task_definition" "this" {
  family = "${var.project_name}-task"

  container_definitions = jsonencode(
    [
      {
        "name" : "${var.project_name}-sample-app-container",
        "image" : "${var.image_path}:${var.image_tag}",
        "entryPoint" : [],
        "essential" : true,
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : "${aws_cloudwatch_log_group.this.id}",
            "awslogs-region" : "${var.region}",
            "awslogs-stream-prefix" : "${var.project_name}-sample-app"
          }
        },
        "portMappings" : [
          {
            "containerPort" : 3000

          }
        ],
        "cpu" : 512,
        "memory" : 1024,
        "networkMode" : "awsvpc"
      }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_task_execution_role_arn

  tags = {
    Name = "${var.project_name}-ecs-task_definition"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = "${var.project_name}-${var.app_name}-logs"

  tags = {
    Name = "${var.project_name}-${var.app_name}-logs"
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.this.family
}

resource "aws_ecs_service" "this" {
  name                 = "${var.project_name}-sample-app-ecs-service"
  cluster              = aws_ecs_cluster.this.id
  task_definition      = "${aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, data.aws_ecs_task_definition.main.revision)}"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = [for subnet in var.private_app_subnets : subnet.id]
    assign_public_ip = false
    security_groups = [
      aws_security_group.service.id
    ]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.project_name}-sample-app-container"
    container_port   = 3000
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }

}

resource "aws_security_group" "service" {
  vpc_id      = var.vpc_id
  name        = "${var.project_name}-${var.app_name}-service-sg"
  description = "Allow inbound access from the ALB only"
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.load_balancer_security_group_id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.app_name}-service-sg"
  }
}

  