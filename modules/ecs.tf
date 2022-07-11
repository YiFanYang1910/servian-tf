#ecs_task_definition, ecs_service, and ecs_cluster
resource "aws_ecs_cluster" "servian_ecs_cluster" {
    name = "${var.ecs_name}_cluster"
    # lifecycle {
    #   setting a lifecycle for this tf, auto destroy
    # }
    #create a cluster
}

resource "aws_ecs_service" "servian_ecs_service" {
    name = "${var.ecs_name}_ecs_service"
    #A service allows you to run and maintain a specified number (the "desired count") of simultaneous instances 
    #of a task definition in an ECS cluster.
    cluster = aws_ecs_cluster.servian_ecs_cluster.id
    #Amazon Resource Name (ARN) of cluster which the service runs on.
    task_definition = aws_ecs_task_definition.servian_task_definition.arn
    #Family and revision or full ARN of the task definition that you want to run in your service.
    desired_count = 2
    #Number of instances of the task definition to place and keep running
    launch_type = "FARGATE"
    #launch type to run service, EC2, Fatgate, external, default is ec2
    #iam_role
    #depends_on
    #if use aws vpc network mode, do not specify this role
    #ARN of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf
    network_configuration {
      security_groups = [aws_security_group.servian_secgroup_task_definition.id]
      subnets = aws_subnet.servian_subnet_private.*.id
      assign_public_ip = true

    }
    load_balancer {
      target_group_arn = aws_alb_target_group.servian_target_group.arn
      #required for ALB/NLB, ARN of the load balancer target group to associate with the service
      container_name = "${var.ecs_name}_container"
      container_port = 3000
    }
    depends_on = [
    aws_alb_listener.servian_alb_listener
    ]
}

#use task definition to set image and container info
resource "aws_ecs_task_definition" "servian_task_definition" {
    family = "${var.ecs_name}_task_definition"
    #unique name for your task definition
    requires_compatibilities = ["FARGATE"]
    #Set of launch types required by the task
    network_mode = "awsvpc"
    #Docker networking mode to use for the containers in the task
    #Valid value: none, bridge, awsvpc, host
    cpu = 1024
    #1 vCPU
    #Number of cpu units used by the task
    memory = 2048
    #2GB
    #amount memory used by the task
    execution_role_arn = aws_iam_role.servian_ecs_exec_role.arn
    task_role_arn = aws_iam_role.servian_ecs_exec_role.arn

container_definitions = <<DEFINITION
[
  {
    "image": "${aws_ecr_repository.servian_ecr.repository_url}",
    "cpu": 1024,
    "memory": 2048,
    "name": "${var.ecs_name}_container",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ]
  }
]
DEFINITION

    #a list of valid container definitions provided, single valid JSON document, the value must be part of the container definition document
    # used in task definition to describe the different containers that are launched as part of the task
    # describe the different containers that ar launched as part of the task
}

resource "aws_iam_role" "servian_ecs_exec_role" {
  name = "servian_ecs_execution_role"
  assume_role_policy = data.aws_iam_policy_document.servian_ecs_role_policy.json
}

data "aws_iam_policy_document" "servian_ecs_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

  
  principals{
    type = "Service"
    identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "servian_ecs_exec_role_policy" {
  role = aws_iam_role.servian_ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  
}