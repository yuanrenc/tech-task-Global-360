.PHONY: plan

TFVARS_FILE = config\dev.tfvars

plan:
	terraform fmt -recursive
	terraform validate
	terraform plan -var-file=$(TFVARS_FILE)
# 	terraform apply -var-file=$(TFVARS_FILE) -auto-approve

