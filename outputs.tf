output "rdp_connection_info" {
  value = <<-EOT
    RDP Connection Details:
    -----------------------
    Full Address: ${aws_instance.win_srv_instance.public_ip}
    Username: Administrator
    Password: ${rsadecrypt(aws_instance.win_srv_instance.password_data, file("~/.ssh/win_srv_key.pem"))}

    Instructions:
    1. Open your RDP client (e.g., Microsoft Remote Desktop).
    2. Enter the 'Full Address' above as the host IP.
    3. Use the 'Username' and 'Password' provided.
    4. When prompted, accept any certificate warnings to proceed.
    EOT
  sensitive = false
}