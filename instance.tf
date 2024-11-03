resource "aws_instance" "win_srv_instance" {
  ami                    = "ami-05bfeaa616a095c81"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.win_srv_public_subnet.id
  vpc_security_group_ids = ["${aws_security_group.win_srv_sg.id}"]
  key_name               = aws_key_pair.win_srv_key.id
  get_password_data      = true


  tags = {
    "Name"      = "${var.env_prefix}_instance"
    "Creator"   = var.creator
    "Terraform" = true
  }
}