#if we need ALB, we need create 2 security groups, 1 ALB security group allows all traffic on the ALB port
# 2 Amazon ECS security group allow all traffic only from the ALB
resource "aws_security_group" "servian_secgroup_alb" {
  name = "${var.security_group}_alb"
  description = "security group for alb to allow/deny traffic"
  vpc_id = aws_vpc.servian_vpc.id

  ingress {
    description = "allowed traffic"
    from_port = 80
    to_port = 80
    #strat to end port range
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # list of cidr_blocks
    # Classless Inter-Domain Routing, a CIDR block is an IP address range
    #list of ipv6 cidr_blocks
  }
  #The load balancer’s security group will only allow traffic to the load balancer on port 80, 
  #as defined by the ingress block within the resource block. Traffic from the load balancer 
  #will be allowed to anywhere on any port with any protocol with the settings in the egress block

  egress{
    description = "blocked traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}



resource "aws_security_group" "servian_secgroup_task_definition"{
    name = "${var.security_group}_task_definition"
    description = "security group for ecs to allow/deny traffic"
    vpc_id = aws_vpc.servian_vpc.id

  ingress {
    description = "allowed traffic"
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    security_groups = [aws_security_group.servian_secgroup_alb.id]
    
  }

  egress{
    description = "blocked traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}
