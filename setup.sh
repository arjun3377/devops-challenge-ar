#!/usr/bin/env bash
# setup.sh — local deployment helper
#
# Builds the image, applies Terraform, installs/upgrades the Helm release.

echo "==> Building Docker image"
#docker build -t skybyte/app:latest .

# cd terraform
# terraform destroy -auto-approve
# cd ..
# helm uninstall kyverno-helm -n kyverno-ns

if helm list -n kyverno-ns | grep -q kyverno-helm; then
  echo "✅ Helm release kyverno-helm already exists in namespace kyverno-ns . Skipping install."
else
  echo "🚀 Installing Kyverno via Helm..."
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno-helm kyverno/kyverno -n kyverno-ns --create-namespace
sleep 45
fi


cd terraform
echo "==> Installing SkyByTech Helm chart via Terraform"
terraform init
terraform apply -auto-approve
cd ..

echo "wait Running System-Checks...."
Sleep 10

bash ./system-checks.sh

echo "==> Done"
