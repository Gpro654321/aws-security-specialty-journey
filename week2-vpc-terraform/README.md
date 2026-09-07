# Week 2 VPC Lab — Terraform Automation

Terraform code that reproduces the Week 2 hands-on lab: a VPC with one public and
one private subnet, following AWS Certified Security – Specialty study track
(Domain 3: Infrastructure Security).

This automates infrastructure originally built manually in the AWS Console, as a
learning exercise in Infrastructure as Code — see the write-up in the main repo
for the manual build and the reasoning behind each design choice.

## What this builds

- 1 VPC (`10.0.0.0/16`)
- 1 public subnet (`10.0.1.0/24`) — auto-assigns public IPs on launch
- 1 private subnet (`10.0.2.0/24`) — no public IP, no direct internet route
- Both subnets pinned to a single Availability Zone (multi-AZ extension planned
  for Week 11)

## Prerequisites

- Terraform >= 1.16.1
- AWS CLI v2, configured with an SSO profile (see `aws configure sso`)
- An active SSO session: `aws sso login --profile <your-profile>`

## Required configuration

This code does **not** ship with a `terraform.tfvars` file — you must create
your own, since it contains your AWS Account ID (used as a safety check, not a
secret, but excluded from version control regardless):

```hcl
# terraform.tfvars (not committed — see .gitignore)
allowed_account_id = "your-account-id-here"
project_tag         = "your-project-name"
```

## Usage

```bash
export AWS_PROFILE=your-profile-name

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Review the `plan` output before every `apply` — in particular, check the
`deploying_to_account` output value matches the account you intend to target.

## Teardown

```bash
terraform destroy
```

Verify independently afterward (console or `aws ec2 describe-vpcs`) — don't
rely solely on the command's success message.

## Cost

VPCs and subnets themselves are free. This configuration currently provisions
no billable resources (no EC2 instances, NAT Gateway, etc. yet) — cost-bearing
resources will be added and documented here as the lab progresses through
later weeks.

## Structure

| File | Purpose |
|---|---|
| `versions.tf` | Terraform + provider version constraints |
| `providers.tf` | AWS provider config, default tags, account safety check |
| `variables.tf` | Input variables (region, CIDRs, AZ, instance type, tags) |
| `main.tf` | Resources (VPC, subnets) and the account identity data source |
| `outputs.tf` | Printed values (target account, resource IDs) |
| `terraform.tfvars` | Local values you supply — **not committed** |

## Status

- [x] VPC
- [x] Public + private subnets
- [ ] Internet Gateway + route table
- [ ] Security group
- [ ] EC2 instances
- [ ] Outputs for instance IPs