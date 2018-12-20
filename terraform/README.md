# AWS ECS, Buildkite and Terraform 

## Usage:

```
cd terraform
export AWS_PROFILE=your_aws_profile
terraform init -backend-config="bucket=your_s3_state_bucket" && terraform apply -var ssh_pubkey_file="$(cat your_ssh_pub_key_path)"
```

### This project are WIP, below points are not yet implemented:

- Create terraform for 2 ALB target groups and 2 ECS service for blue-green deployment.
- A script to Swap between Listener rules in both target groups.
- Integrate the Swapping script in Buildkite.


### Overview:
![ECS Deployment](img/ECS_blue_green.jpg)
