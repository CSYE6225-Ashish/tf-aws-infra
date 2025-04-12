# tf-aws-infra

# Terraform VPC and Subnet Setup

This Terraform configuration sets up a basic **Virtual Private Cloud (VPC)** with **public** and **private subnets** on AWS. It includes the following components:

1. **VPC**: A virtual private cloud to logically isolate your network in AWS.
2. **Public Subnets**: Subnets that have internet access, used for resources like web servers.
3. **Private Subnets**: Subnets that do not have direct internet access, used for resources like databases.
4. **Internet Gateway**: To allow internet access for resources in the public subnets.
5. **Route Tables**: To manage traffic flow between public and private subnets and the internet.

## Requirements

- **Terraform**: Version 1.2.0 or greater is required.
- **AWS Provider**: Version `>= 5.87.0` and `< 7.0.0`.
- **AWS Profile**: Make sure to set up your AWS CLI profile and pass it as a variable (`profile`) for authentication.

## Terraform Provider Configuration

The configuration is set up to use the **AWS** provider. The provider version is specified as `>= 5.87.0` and `< 7.0.0`.

```hcl
provider "aws" {
  profile = var.profile
  region  = var.region
}
```

You can specify your AWS credentials in your `AWS_PROFILE` (or other methods based on AWS CLI configuration).

## AWS Resources Created

### 1. **AWS VPC**
The configuration creates a **VPC** (Virtual Private Cloud) using the CIDR block specified by the `var.vpc.cidr` variable.

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc.cidr
  tags = {
    Name = var.vpc.name
  }
}
```

### 2. **Public Subnets**
The public subnets are created using the `cidrsubnet` function to calculate different CIDR blocks for each subnet. These subnets are placed in different availability zones, and `map_public_ip_on_launch` is set to `true` to allow instances in these subnets to have public IPs.

```hcl
resource "aws_subnet" "public" {
  count                   = local.zone_logic
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, local.new_bit, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}
```

### 3. **Private Subnets**
Private subnets are created similarly to public subnets, but `map_public_ip_on_launch` is set to `false` to ensure that instances in these subnets do not have public IPs.

```hcl
resource "aws_subnet" "private" {
  count                   = local.zone_logic
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, local.new_bit, (count.index + local.zone_logic))
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}
```

### 4. **Internet Gateway**
An **Internet Gateway** is created and attached to the VPC, allowing public subnets to access the internet.

```hcl
resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Internet Gateway for ${aws_vpc.main.id}"
  }
}
```

### 5. **Route Tables**
The configuration creates separate **route tables** for public and private subnets.

- **Public Route Table**: Includes a default route to the internet via the Internet Gateway.

```hcl
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGateway.id
  }
  tags = {
    Name = "Public route table for ${aws_vpc.main.id}"
  }
}
```

- **Private Route Table**: Does not include a default route to the internet (for private subnet isolation).

```hcl
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Private route table for ${aws_vpc.main.id}"
  }
}
```

### 6. **Route Table Associations**
The subnets are associated with the appropriate route tables:

- **Public Subnet Route Table Association**: Each public subnet is associated with the public route table.

```hcl
resource "aws_route_table_association" "aws_route_table_public" {
  for_each       = local.public_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.public_route_table.id
}
```

- **Private Subnet Route Table Association**: Each private subnet is associated with the private route table.

```hcl
resource "aws_route_table_association" "aws_route_table_private" {
  for_each       = local.private_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.private_route_table.id
}
```

## Variables

The following variables need to be defined for the configuration to work:

- `profile`: Your AWS CLI profile to authenticate.
- `region`: The AWS region to create resources in.
- `vpc`: Contains the CIDR block and name of the VPC.
- `zone_logic`: The number of availability zones for public and private subnets.
- `new_bit`: The bit-shift used to calculate subnet CIDRs.

## Example Variable Definition

Example of how to define the variables in `terraform.tfvars`:

```hcl
profile = "my-aws-profile"
region  = "us-west-2"

vpc = {
  cidr = "10.0.0.0/16"
  name = "my-vpc"
}

zone_logic = 2
new_bit = 8
```

## Outputs

To retrieve useful information after deployment, you can define outputs like the VPC ID, subnet IDs, etc. Example:

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}
```

## How to Use

1. Clone this repository or copy the Terraform configuration files into your own project.
2. Set up your AWS CLI profile (`aws configure`).
3. Initialize the Terraform working directory by running:

   ```bash
   terraform init
   ```

4. Apply the Terraform configuration to create the VPC and related resources:

   ```bash
   terraform apply
   ```

5. After applying, the resources will be created, and you can see the output variables like the VPC ID.

## Clean Up

To delete the resources created by Terraform, run:

```bash
terraform destroy
```

Certainly! Here's a content-only section for the **README** file to explain the GitHub Actions workflow for Terraform validation in a pull request:

---

## Pull Request Terraform Validation Check

This GitHub Actions workflow in .workflow/pr-merge-check.yml is designed to automatically validate Terraform configurations in pull requests targeting the `main` branch. It helps ensure that the Terraform code in pull requests is properly formatted, initialized, and validated before being merged.

### Workflow Trigger

This workflow is triggered by the following events:
- A **pull request** is **opened** or **reopened** that targets the `main` branch.

### Workflow Steps

The workflow consists of the following key steps:

1. **Checkout Pull Request Code**  
   The code from the pull request is checked out using the `actions/checkout@v4` action, allowing Terraform commands to be executed against the pulled code.

2. **Setup Terraform**  
   The `hashicorp/setup-terraform@v3` action sets up the specified version of Terraform (in this case, `1.10.4`) for use in the workflow.

3. **Check Terraform Formatting**  
   The `terraform fmt -check -recursive` command is run to check if the Terraform files in the repository follow the proper formatting conventions. This step ensures that all `.tf` files are formatted correctly.

4. **Initialize Terraform**  
   The `terraform init` command is executed to initialize the Terraform working directory, downloading the necessary provider plugins and preparing the configuration for validation.

5. **Validate Terraform Configuration**  
   The `terraform validate` command is used to check if the Terraform configuration is syntactically correct and if it can be applied without errors.


6. Adding certificate using AWS CLI

    Following command was used to create a certificate in demo account:\n
    `aws acm import-certificate --profile demo --certificate fileb://demo_ashishgangaramani_me.crt --certificate-chain fileb://demo_ashishgangaramani_me.ca-bundle --private-key fileb://RSAPRIVATEKEY.pem`
    Output:
    `{
      "CertificateArn": "arn:aws:acm:us-east-1:343218179908:certificate/12e8a4ca-d7df-454f-8db2-4bb78897a19f"
    }`



### Purpose

The goal of this workflow is to automatically verify Terraform code for consistency, syntax, and correctness before changes are merged into the main branch. By catching potential errors early, it helps improve the quality and reliability of the infrastructure code.

