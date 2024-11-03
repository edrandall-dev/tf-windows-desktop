# AWS Windows Server Deployment with Terraform

This repository contains a set of Terraform configurations to deploy a Windows Server instance on AWS. The setup provisions a secure infrastructure with a VPC, subnet, internet gateway, route table, and a security group configured for RDP access. The configuration also sets up an SSH key pair for secure access and outputs the necessary information for RDP connection.

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Use Case](#use-case)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Outputs](#outputs)
- [Security Considerations](#security-considerations)

## Overview
This Terraform project sets up the following AWS infrastructure components:
- A **VPC** with DNS support.
- A **public subnet** for the Windows Server instance.
- An **Internet Gateway** for external connectivity.
- A **route table** and **route table association** to route internet traffic.
- A **security group** configured to allow RDP access.
- A **Windows Server EC2 instance** with RDP access enabled and password retrieval capability.
- **Key pair generation** to secure access.

## Architecture
The deployed architecture includes:
- **VPC**: A custom VPC for the environment.
- **Subnet**: A public subnet within the VPC.
- **Internet Gateway**: Provides internet connectivity to the subnet.
- **Security Group**: Configured for RDP (port 3389) access.
- **EC2 Instance**: A Windows Server instance deployed in the public subnet.

## Use Case
This Terraform configuration is ideal for those who need a temporary Windows environment for testing, development, or troubleshooting purposes. It allows for quick provisioning of a Windows Server that can be used without incurring costs if the **AWS Free Tier** is utilised. To avoid unexpected charges, it is recommended to set up a **billing alarm** in AWS when creating a new account. Additionally, ensure that the Terraform environment is torn down when not in use to prevent any costs from being incurred.

## Prerequisites
Before using this Terraform configuration, ensure you have:
- **Terraform** installed on your local machine.
- **AWS CLI** configured with the necessary credentials.
- An **existing public SSH key** for EC2 key pair creation.
- Necessary permissions in your AWS account to create VPCs, subnets, EC2 instances, etc.

## Usage
1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Update variables**:
   Modify the `terraform.tfvars` or pass variables using the command line to set the appropriate values for:
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
   Confirm the plan by typing `yes` when prompted.

6. **Tear down the environment when done**:
   ```bash
   terraform destroy
   ```
   This will ensure that resources are terminated, reducing the risk of any costs being incurred.

## Outputs
The configuration provides an output with the necessary details for connecting to the Windows Server instance:

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

**Note**: The output `rdp_connection_info` will display sensitive information. Ensure you handle this output securely.

## Security Considerations
- **Key Management**: Keep your private key file secure and restrict access to it.
- **Security Group**: The provided security group configuration allows RDP access from any IP (`0.0.0.0/0`). Modify this for more restricted access (e.g., your IP only) for improved security.
- **Password Handling**: The `rsadecrypt` function decrypts the Windows Administrator password and outputs it. Handle this password securely and ensure that only authorised personnel have access.
- **Billing Alarms**: Set up an AWS billing alarm to monitor usage and avoid unexpected charges.
- **Environment Teardown**: Always run `terraform destroy` after completing your tasks to ensure that resources are deleted and no unnecessary charges are incurred.
- **Certificate Warnings**: Users will encounter a certificate warning when connecting to the RDP session. Ensure you trust the server and accept the certificate prompt to proceed.

