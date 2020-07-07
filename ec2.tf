provider "aws"{
    region="ap-south-1"
    profile="new"
}
resource "aws_instance" "dhruv"{
    ami="ami-0447a12f28fddb066"
    instance_type="t2.micro"
}