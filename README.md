# AWS Windows Server Deployment with Terraform

This is a simple Terraform configuration for deploying a Windows Server instance on AWS—a useful setup if you occasionally need a quick Windows environment for testing, development, or troubleshooting. It provisions a basic infrastructure including a VPC, subnet, and an RDP-accessible Windows Server instance. Access is restricted to your own IP address to provide a reasonable layer of security without over-complicating things.

## Overview
This Terraform project sets up the following AWS components:
- A **VPC** with DNS support for network isolation.
- A **public subnet** to house the Windows Server instance.
- An **Internet Gateway** for internet connectivity.
- A **route table** to handle internet routing for the subnet.
- A **security group** configured to allow RDP access, restricted to your current IP address.
- A **Windows Server EC2 instance** with AWS-managed password retrieval.
- **Key pair configuration** for secure access.

## Use Case
This setup is intended for short-term, dev-oriented use cases. It’s perfect if you need a Windows server quickly but don’t want to commit to a permanent setup. If you’re using the **AWS Free Tier**, you can avoid incurring extra costs. However, I recommend setting up a **billing alarm** in AWS and tearing down the environment when you're finished to avoid any unexpected charges. 

## Prerequisites
To use this Terraform configuration, ensure you have:
- **Terraform** installed on your machine.
- **AWS CLI** configured with necessary credentials.
- An **existing public SSH key** for creating the EC2 key pair.
- Sufficient permissions in AWS to create VPCs, subnets, and EC2 instances.

## Restricting Access to Your IP Address
The security group is set up to allow RDP access only from your current IP address. This is achieved by using the public IP returned by `icanhazip.com`. Note that if this HTTP request fails, Terraform won’t be able to retrieve your IP address, and the setup may fail. You’ll need to re-run `terraform apply` once the IP retrieval is successful.

## Usage
1. **Clone the repository**:
   ```bash
   git clone https://github.com/edrandall-dev/tf-windows-desktop
   cd tf-windows-desktop
   ```

2. **Set up variables**:
   Update the `terraform.tfvars` or specify variables on the command line for:
   - `region`
   - `base_cidr_block`
   - `creator`
   - `env_prefix`
   - `instance_type`
   - `public_key_path`

3. **Initialise Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the infrastructure**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```
   Confirm by typing `yes` when prompted.

6. **Tear down the environment**:
   ```bash
   terraform destroy
   ```
   This will delete all resources to avoid unwanted costs.

## Outputs
After applying the configuration, you’ll get an output with the necessary details for RDP access:

```hcl
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
  sensitive = true
}
```

**Note**: This output includes sensitive information, so handle it securely.

## Security Considerations
This configuration is intentionally simplified for a quick dev environment and doesn’t follow all production-level security practices. Here’s a rundown of the security setup:
- **Key Management**: Keep your private key secure, as it’s required to decrypt the AWS-provided Windows Administrator password.
- **Security Group**: By default, this configuration restricts RDP access to your IP only. However, if IP retrieval fails, the configuration won’t apply correctly. Re-run Terraform once your IP can be retrieved.
- **Password Handling**: The password is decrypted and displayed in Terraform’s output. 
- **Environment Teardown**: Always run `terraform destroy` when you’re finished to prevent lingering charges and minimise exposure.

## Further Changes
If you want to create custom AMI for use each time which includes some customisations, then the following files can be modified:

```
#instance.tf
resource "aws_instance" "win_srv_instance" {
  //Generic Windows 2022 Server AMI
  //ami                    = "ami-05bfeaa616a095c81"
  //get_password_data      = true
  
  //My own customised Windows 2022 Server AMI
  ami = "ami-0e43f9f00673b162e"
  get_password_data      = false

  instance_type          = var.instance_type
  subnet_id              = aws_subnet.win_srv_public_subnet.id
  vpc_security_group_ids = ["${aws_security_group.win_srv_sg.id}"]
  key_name               = aws_key_pair.win_srv_key.id

  tags = {
    "Name"      = "${var.env_prefix}_instance"
    "Creator"   = var.creator
    "Terraform" = true
  }
}

#outputs.tf
output "rdp_connection_info" {
  value = <<-EOT
    RDP Connection Details:
    -----------------------
    Full Address: ${aws_instance.win_srv_instance.public_ip}
    Username: Administrator
    //Password: ${rsadecrypt(aws_instance.win_srv_instance.password_data, file("~/.ssh/win_srv_key.pem"))}

    Instructions:
    1. Open your RDP client (e.g., Microsoft Remote Desktop).
    2. Enter the 'Full Address' above as the host IP.
    3. Use the 'Username' and 'Password' provided.
    4. When prompted, accept any certificate warnings to proceed.
    EOT
  sensitive = false
}
```