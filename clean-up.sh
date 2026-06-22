#!/usr/bin/env bash

cd terraform
terraform destroy -auto-approve
cd ..
helm uninstall kyverno-helm -n kyverno-ns