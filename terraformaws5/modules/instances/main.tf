resource "aws_instance" "public_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_security_group_id]
  key_name               = var.key_name

  tags = {
    Name = "Public-Instance"
  }
}

# IAM Role for EC2 (S3 Read/Write Permissions)
resource "aws_iam_role" "ec2_role" {
  name               = "EC2RoleWithS3Access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# S3 Read/Write Policy (Download scripts & Upload Kafka backups)
resource "aws_iam_policy" "s3_read_write_policy" {
  name        = "S3ReadWritePolicy"
  description = "Allows EC2 to read from and write backups to a specific S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::parashar089",        # List bucket contents
          "arn:aws:s3:::parashar089/*"       # Read & Write files in the bucket
        ]
      }
    ]
  })
}

# Attach S3 Read/Write Policy to EC2 Role
resource "aws_iam_role_policy_attachment" "ec2_role_s3_rw_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_write_policy.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_role" {
  name = "EC2InstanceProfileWithS3Access"
  role = aws_iam_role.ec2_role.name
}

# Private Instance with SSH Key and user_data
resource "aws_instance" "private_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.private_security_group_id]
  key_name               = var.key_name

  tags = {
    Name = "Private-Instance"
  }
  iam_instance_profile = aws_iam_instance_profile.ec2_role.name  # Associate the IAM instance profile
  
  # User data script to run the installation and configuration
  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
    "sudo apt update -y",
    # Install prerequisites
      "sudo apt update -y",
      "sudo apt install -y unzip curl",  # Install unzip and curl

      # Install AWS CLI
      "curl \"https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "aws --version",  # Verify installation

    ]
    connection {
      type                = "ssh"
      user                = "ubuntu"
      private_key         = file(var.private_key_path)
      host                = self.private_ip
      bastion_host        = var.bastion_host
      bastion_user        = "ubuntu"
      bastion_private_key = file(var.private_key_path)
    }
  }
}

# Network Load Balancer (NLB)
resource "aws_lb" "kafka_nlb" {
  name               = "kafka-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [var.public_subnet_id]

  tags = {
    Name = "Kafka-NLB"
  }
}

# NLB Target Group
resource "aws_lb_target_group" "kafka_tg" {
  name     = "kafka-target-group"
  port     = 9092
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = 9092
    interval            = 300
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "Kafka-Target-Group"
  }
}

# Add Listener to the NLB on port 9092
resource "aws_lb_listener" "kafka_nlb_listener" {
  load_balancer_arn = aws_lb.kafka_nlb.arn
  port              = 9092
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kafka_tg.arn
  }
}

# Attach EC2 instance to Target Group
resource "aws_lb_target_group_attachment" "kafka_target" {
  target_group_arn = aws_lb_target_group.kafka_tg.arn
  target_id        = aws_instance.private_instance.id
  port             = 9092
}
