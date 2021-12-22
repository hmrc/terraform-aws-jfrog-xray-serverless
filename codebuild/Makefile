SHELL := /bin/bash

.PHONY: clean
clean:
	rm -rf .terraform

.PHONY: init_labs
init_labs: clean
	terraform init -backend-config="bucket=terraform-aws-jfrog-xray-serverless-pipeline-state-labs"

.PHONY: init_live
init_live: clean
	terraform init -backend-config="bucket=terraform-aws-jfrog-xray-serverless-pipeline-state-live"
