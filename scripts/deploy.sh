#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# One-command deploy from your machine (same steps as the GitHub Actions job).
#
# Prereqs: aws CLI (logged in), terraform >= 1.10, docker, jq, curl
#
#   export TF_STATE_BUCKET=<from bootstrap output>
#   export HOSTINGER_API_TOKEN=<hPanel API token>     # only if a domain is set
#   cp infra/app/terraform.tfvars.example infra/app/terraform.tfvars   # edit it
#   ./scripts/deploy.sh
# -----------------------------------------------------------------------------
set -euo pipefail
cd "$(dirname "$0")/.."

: "${TF_STATE_BUCKET:?export TF_STATE_BUCKET (see infra/bootstrap output)}"
AWS_REGION=${AWS_REGION:-ap-south-1}
IMAGE_TAG=${IMAGE_TAG:-$(git rev-parse --short=12 HEAD 2>/dev/null || date +%Y%m%d%H%M%S)}
if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
  IMAGE_TAG="${IMAGE_TAG}-dirty-$(date +%s)"   # tags are immutable; never reuse one for different code
fi
export TF_VAR_image_tag=$IMAGE_TAG TF_VAR_aws_region=$AWS_REGION

TF="terraform -chdir=infra/app"

echo "==> terraform init"
$TF init -input=false \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="key=fruitbazar/prod.tfstate" \
  -backend-config="region=${AWS_REGION}" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"

echo "==> ensure ECR repository"
$TF apply -auto-approve -input=false -target=aws_ecr_repository.app -target=aws_ecr_lifecycle_policy.app
ECR_URL=$($TF output -raw ecr_repository_url)

echo "==> build & push ${ECR_URL}:${IMAGE_TAG}"
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "${ECR_URL%%/*}"
if ! aws ecr describe-images --region "$AWS_REGION" --repository-name "${ECR_URL##*/}" --image-ids imageTag="$IMAGE_TAG" >/dev/null 2>&1; then
  docker buildx build --platform linux/amd64 -t "${ECR_URL}:${IMAGE_TAG}" --push .
else
  echo "    image already exists, skipping build"
fi

echo "==> terraform apply (VPC, SGs, RDS, ALB, TLS, DNS, ECS)"
$TF apply -auto-approve -input=false

echo
echo "Done. Site: $($TF output -raw app_url)"
