#vpc, az, subnet, internet_gateway,route/route_table
data "aws_availability_zones" "servian_az" {
    state = "available"
}


resource "aws_vpc" "servian_vpc" {
    //name = "${var.ecs_name}_vpc"
    cidr_block = "10.32.0.0/16"
  
}
#subnet-- private/ public,
resource "aws_subnet" "servian_subnet_public" {
    vpc_id = aws_vpc.servian_vpc.id
    cidr_block = cidrsubnet(aws_vpc.servian_vpc.cidr_block, 8, 2 + count.index)
    #{vpc's cidr_block}'s 子集
    #The IPv4 CIDR block for the subnet.
    count = 2
    availability_zone = data.aws_availability_zones.servian_az.names[count.index]
    #random az, 2 for aws origion
    map_public_ip_on_launch = true
    #Specify true to indicate that instances launched into the subnet should be assigned a public IP address
}

resource "aws_subnet" "servian_subnet_private" {
    vpc_id = aws_vpc.servian_vpc.id
    cidr_block = cidrsubnet(aws_vpc.servian_vpc.cidr_block, 8,count.index)
    count = 2
    availability_zone = data.aws_availability_zones.servian_az.names[count.index]
}
#define public-facing things will added to public subnet
#things dont need to communicate with the internet directly
resource "aws_internet_gateway" "servian_gateway" {
    vpc_id = aws_vpc.servian_vpc.id
    #The VPC ID to create in 
}
 # if necessary, can add EIP here, which is a reserved public IP that can assign to any EC2 instance

 #nat gateway, highly available AWS managed service that makes it easy to connect to the internet from instances within a private subnet in VPC

 #routing table moves the traffic inside a VPC that is coming from the gateway and divides it among subnets. 
 #Each VPC has a default route table that is connected to each subnet.

 resource "aws_route" "servian_route" {
    #route the traffic, define the destination
    route_table_id = aws_vpc.servian_vpc.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.servian_gateway.id
   
 }

 resource "aws_route_table" "servian_private_route_table" {
    #define private route table
    #contains a set of rules, called routes, 
    #that determine where network traffic from your subnet or gateway is directed
    count = 2
    vpc_id = aws_vpc.servian_vpc.id
 }

 resource "aws_route_table_association" "servian_private_route_table_ass" {
    #The association between a route table and a subnet, internet gateway, or virtual private gateway
    #create an association between a route table and a subnet 
    #or a route table and an internet gateway or virtual private gateway.
    count = 2   
    subnet_id = element(aws_subnet.servian_subnet_private.*.id, count.index)
    route_table_id = element(aws_route_table.servian_private_route_table.*.id, count.index)
   
 }

 #used to handle networking and communication to and from the internet outside of the VPC,
 #internet gateway: what allows to communication between the VPC and the internet at all
 #NAT gateway allows resources within the VPC to communicate with the internet 
 #but will prevent communication to the VPC from outside sources

 #That is all tied together with the route table association, 
 #where the private route table that includes the NAT gateway is added to the private subnets defined earlier
