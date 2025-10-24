#!/bin/bash
# Bootstrap OIDC Provider and IAM Role for GitHub Actions

set -e  # Exit on error

echo "=========================================="
echo "  Bootstrapping OIDC for GitHub Actions"
echo "=========================================="
echo ""

# Get script directory and navigate to terraform directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../terraform"

echo "📋 Applying OIDC Provider and IAM Role..."
echo ""

terraform apply \
  -target=module.oidc.aws_iam_openid_connect_provider.github \
  -target=module.oidc.aws_iam_role.github_actions \
  -target=module.oidc.aws_iam_policy.github_actions \
  -target=module.oidc.aws_iam_role_policy_attachment.github_actions_policy \
  -auto-approve

echo ""
echo "=========================================="
echo "  ✅ OIDC Bootstrap Complete!"
echo "=========================================="
echo ""
echo "📌 GitHub Actions Role ARN:"
terraform output -raw github_actions_role_arn
echo ""
echo ""
echo "=========================================="
echo "  Next Steps:"
echo "=========================================="
echo "  1. Add this role ARN to your GitHub repository secret:"
echo "     - AWS_ROLE_ARN"
echo ""
echo "  2. Ensure your GitHub repository matches: $(terraform output -raw github_actions_role_arn | grep -o 'repo:[^:]*' | cut -d: -f2 || echo 'Yasinhirsi/ECS-oidc-blue-green-url-shortener')"
echo ""
echo "  3. Push workflows to GitHub to trigger automated deployments"
echo "=========================================="
echo ""
