resource "aws_instance" "weblogic" {
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
              apt-get install -y openjdk-17-jre wget unzip
              useradd -m weblogic || true
              mkdir -p /u01/oracle/weblogic
              chown -R weblogic:weblogic /u01/oracle/weblogic
              EOF

  tags = { Name = "${var.name_prefix}-weblogic" }
}
