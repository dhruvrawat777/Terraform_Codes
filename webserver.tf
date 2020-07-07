resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http"
  vpc_id      = "vpc-1ddfe775"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_instance" "web"{
  ami="ami-0447a12f28fddb066"
  instance_type="t2.micro"
  key_name="new"
  security_groups=["allow_http"]
  
  connection {
    type="ssh"
    user="ec2-user"
    private_key=file("C:/Users/HP/Downloads/AWS_KEYS/new.pem")
    host=aws_instance.web.public_ip
  }

  provisioner "remote-exec" {
    inline=[
       "sudo yum install httpd php git -y",
       "sudo systemctl restart httpd",
       "sudo systemctl enable httpd",
    ]
  }
  tags={
    Name="dhruv"
  }
}

resource "aws_ebs_volume" "esb1"{
  availability_zone=aws_instance.web.availability_zone
  size=1
  tags={
    name="dhruv"
  }
}

resource "aws_volume_attachment" "ebs_att"{
    device_name="/dev/sdh"
    volume_id="${aws_ebs_volume.esb1.id}"
    instance_id="${aws_instance.web.id}"
    force_detach=true
}


output "myos_ip"{
  value=aws_instance.web.public_ip
}


resource "null_resource" "nullremote3"{
  
  depends_on=[aws_volume_attachment.ebs_att,]

  connection{
    type="ssh"
    user="ec2-user" 
    private_key=file("C:/Users/HP/Downloads/AWS_KEYS/new.pem")
    host=aws_instance.web.public_ip
  }
  provisioner "remote-exec"{
    inline=[
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xvdh /var/www/html",
      "sudo rm -rf /var/www/html/* ",
      "sudo git clone https://github.com/dhruvrawat777/multicloud.git /var/www/html"
    ]
  }
}

resource "null_resource" "nulllocal1"{
  depends_on=[null_resource.nullremote3,]

   provisioner "local-exec"{
     command="start chrome ${aws_instance.web.public_ip}"
    }
}
