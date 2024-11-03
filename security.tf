resource "aws_security_group" "win_srv_sg" {
  name   = "win_srv_sg"
  vpc_id = aws_vpc.win_srv_vpc.id


  # RDP access from anywhere, uncomment if needed

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # No restrictions on traffic originating from inside the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.base_cidr_block}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"      = "${var.env_prefix}_sg"
    "Creator"   = var.creator
    "Terraform" = true
  }
}