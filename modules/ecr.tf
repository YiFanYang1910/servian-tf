resource "aws_ecr_repository" "servian_ecr" {
    #use ecr to store image
    name = var.ecr_name
    #name of the repo
    image_tag_mutability = "MUTABLE"
    #the tag mutability seeting for the repo, one of the mutable or immutable, default mutable
    #标签可变性设置
    image_scanning_configuration {
      scan_on_push = true
      #Configuration block that defines image scanning configuration for the repository.
      #Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false).
    }

}