#!/usr/bin/env bash
# setup.sh — local deployment helper
#
# Builds the image, applies Terraform, installs/upgrades the Helm release.

echo "==> Building Docker image"
#docker build -t skybyte/app:latest .

cd terraform
terraform destroy -auto-approve
cd ..

helm uninstall kyverno-helm -n kyverno-ns

helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno-helm kyverno/kyverno -n kyverno-ns --create-namespace

sleep 45
echo "==> Applying Terraform"
cd terraform
terraform init
terraform apply -auto-approve
cd ..

#echo "==> Installing Helm chart"
#helm upgrade --install skybyte-app helm/skybyte-app \
#  --namespace devops-challenge

echo "==> Done"
