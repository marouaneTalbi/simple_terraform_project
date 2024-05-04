resource "aws_instance" "app_server" {
  ami                    = "ami-087da76081e7685da"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = "aws-ssh-key"

  depends_on = [aws_key_pair.aws_key_for_ec2]

  connection {
    type        = "ssh"
    user        = "admin"
    private_key = file("/Users/marouane/.ssh/aws-ssh-key")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install -y nodejs npm",
      "sudo npm install pm2 -g",
      "sudo npm install -g n",
      "sudo n stable",
      "git clone https://github.com/marouaneTalbi/imple_node_api.git",
      "cd imple_node_api",
      "npm install",
      "sudo pm2 start app.js"
    ]
  }

  tags = {
    Name = "ec2-esgi-3"
  }
}
