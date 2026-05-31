resource "aws_instance" "tomcat" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              set -eux
              apt-get update -y
              apt-get install -y openjdk-17-jre wget
              useradd -m tomcat || true
              mkdir -p /opt/tomcat
              cd /tmp
              wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.28/bin/apache-tomcat-10.1.28.tar.gz
              tar -xzf apache-tomcat-10.1.28.tar.gz
              cp -R apache-tomcat-10.1.28/* /opt/tomcat/
              chown -R tomcat:tomcat /opt/tomcat
              EOF

  tags = { Name = "${var.name_prefix}-tomcat" }
}
