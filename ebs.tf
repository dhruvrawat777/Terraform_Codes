resource "aws_ebs_volume" "dhruv" {
  availability_zone = "ap-south-1a"
  size              = 1

  tags = {
    Name = "dhruvv"
  }
}