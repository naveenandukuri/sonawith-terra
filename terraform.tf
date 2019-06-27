provider "aws" {}

resource "aws_instance" "sonar" {
    ami             = "ami-0503db1a235b15e3f"
    instance_type   = "t2.medium"
    
     provisioner "remote-exec" {
        connection {
            type     = "ssh"
            user     = "centos"
            private_key = "${file("/home/centos/.ssh/id_rsa")}"
          }
        inline = [
        "curl -s https://raw.githubusercontent.com/linuxautomations/sonarqube/master/install.sh | sudo bash",
        ]
    } 
}
