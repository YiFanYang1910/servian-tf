resource "aws_alb" "servian_alb" {
    name = "servian-alb"
    subnets = aws_subnet.servian_subnet_public.*.id
    security_groups = [aws_security_group.servian_secgroup_alb.id]
}

resource "aws_alb_target_group" "servian_target_group" {
    name = "servian-target-group"
    target_type = "ip"
    port = 80
    #Port on which targets receive traffic, unless overridden when registering a specific target
    #dont need if type is lambda
    protocol = "HTTP"
    #protocol to routing traffic to the target, one of the Geneve, HTTP,HTTPS,TCP,TCP_UDP,TLS or UDP
    #dont need if type is lambda
    vpc_id = aws_vpc.servian_vpc.id
    #identifier of the VPC in which to create the target_group
    #dont need if type is lambda
}

resource "aws_alb_listener" "servian_alb_listener" {
    load_balancer_arn = aws_alb.servian_alb.id
    port = 80
    protocol = "HTTP"
    

    default_action {
        target_group_arn =aws_alb_target_group.servian_target_group.id
        type = "forward"
    }
  #defines the load balancer itself and attaches it to the public subnet in each availability zone with the load balancer security group. 
  #The target group, when added to the load balancer listener tells the load balancer to forward incoming traffic on port 80 to wherever the load balancer is attached. 
}