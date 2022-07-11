variable "ecs_name" {
    description = "the name of the ecs_cluster"
    type = string
}

variable "ecr_name" {
    description = "the name of the ecr repo"
    type = string
  
}

variable "security_group" {
    description = "the front name of the 2 security group"
    type = string
  
}

variable "db_name" {
    description = "the name of RDS"
    type = string
    default = "servian_test_db"
  
}