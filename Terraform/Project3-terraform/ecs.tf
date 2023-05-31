resource "aws_ecs_task_definition" "service" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "service-first"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
    { 
      name      = "second"
      image     = "service-second"
      cpu       = 10
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 443
          hostPort      = 443
        }
      ]
    }
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}

resource "aws_default_security_group" "main" {
  name = "example-task-security-group"
  vpc_id = aws_vpc.main.id
  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster"
}

# replace mongo with name of project
resource "aws_ecs_service" "mongo" {
  name            = "mongodb"
  cluster         = aws_ecs_cluster.foo.id # may need to swith foo to main
  task_definition = aws_ecs_task_definition.mongo.arn
  desired_count   = 3                # may swap "number" with "var.app_count"
  iam_role        = aws_iam_role.foo.arn
  depends_on      = [aws_iam_role_policy.foo]

    # may remove if applicable
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

    # change mongo to container name
  load_balancer {
    target_group_arn = aws_lb_target_group.foo.arn
    container_name   = "mongo"
    container_port   = 8080
  }

  network configuration {
    security_groups   = [aws_security_group.fill_in_name_here_task.id]
    subnets   = aws_subnet.private.*.id
  }
    # may remove if applicable
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}

output "sg_id" {
  value = aws_security_group.sg.id
}