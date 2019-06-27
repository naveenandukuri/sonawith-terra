provider "aws" {}

resource "aws_instance" "sonar" {
    ami             = "ami-0503db1a235b15e3f"
    instance_type   = "t2.medium"
    
     provisioner "remote-exec" {
        connection {
            type     = "ssh"
            user     = "centos"
            private_key = "${file("/home/centos/.ssh/id_rsa")}"
            vpc_security_group_ids = ["sg-ff6b6ab6"]
          }
        inline = [
        "curl -s https://raw.githubusercontent.com/linuxautomations/sonarqube/master/install.sh | sudo bash",
        ]
    } 
}
