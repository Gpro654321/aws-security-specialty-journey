## Terraform learnings
There should always be .gitignore which holds the following
*.tfstate
*.tfstate.backup
*.tfvars

Always run terraform plan before apply.

There should be a output which shows to which aws account the infrastructure changes are being affected to

The AWS_PROFILE shoule be exported as an environment variable and not be hardcoded in the terraform code

The providers.tf contains a default_tags which will applied to all resources by default (I have the project_tag here)

Tags are very important and NOT a nice to have.
	- When someone wants list resource based on a project it helps a lot
	- Especially billing, terraform destroy etc..


