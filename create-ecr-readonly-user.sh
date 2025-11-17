#!/bin/bash

# Configuration
IAM_USERNAME="xav-test-ecr-readonly-customer"
POLICY_NAME="xav-test-ECR-ReadOnly-Specific-Repos"
AWS_ACCOUNT_ID="923411875752"
AWS_REGION="us-east-1"

# Create the IAM user
echo "Creating IAM user: ${IAM_USERNAME}"
aws iam create-user --user-name ${IAM_USERNAME}

# Create a custom policy for read-only access to specific repositories
echo "Creating IAM policy for ECR read-only access to specific repositories"
cat > /tmp/ecr-readonly-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "GetAuthorizationToken",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ReadOnlyAccessToSpecificRepos",
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:DescribeImageScanFindings",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:ListTagsForResource"
            ],
            "Resource": [
                "arn:aws:ecr:${AWS_REGION}:${AWS_ACCOUNT_ID}:repository/xav-test-apache",
                "arn:aws:ecr:${AWS_REGION}:${AWS_ACCOUNT_ID}:repository/xav-test-php",
                "arn:aws:ecr:${AWS_REGION}:${AWS_ACCOUNT_ID}:repository/xav-test-chart"
            ]
        }
    ]
}
EOF

# Create the policy
echo "Creating policy: ${POLICY_NAME}"
POLICY_ARN=$(aws iam create-policy \
    --policy-name ${POLICY_NAME} \
    --policy-document file:///tmp/ecr-readonly-policy.json \
    --description "Read-only access to specific ECR repositories for customer" \
    --query 'Policy.Arn' \
    --output text)

echo "Policy created with ARN: ${POLICY_ARN}"

# Attach the policy to the user
echo "Attaching policy to user"
aws iam attach-user-policy \
    --user-name ${IAM_USERNAME} \
    --policy-arn ${POLICY_ARN}

# Create access keys for the user
echo "Creating access keys for user"
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name ${IAM_USERNAME})

# Extract the access key and secret
ACCESS_KEY_ID=$(echo ${ACCESS_KEY_OUTPUT} | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo ${ACCESS_KEY_OUTPUT} | jq -r '.AccessKey.SecretAccessKey')

# Save credentials to a file
cat > /tmp/ecr-readonly-credentials.txt << EOF
ECR Read-Only Access Credentials
=================================
AWS Access Key ID: ${ACCESS_KEY_ID}
AWS Secret Access Key: ${SECRET_ACCESS_KEY}
AWS Region: ${AWS_REGION}

Docker Login Command:
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

Available Repositories:
- ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/xav-test-apache
- ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/xav-test-php
- ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/xav-test-chart

Helm Chart Installation:
helm install opencart oci://${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/xav-test-chart
EOF

echo ""
echo "==========================================="
echo "User created successfully!"
echo "==========================================="
echo "Username: ${IAM_USERNAME}"
echo "Policy ARN: ${POLICY_ARN}"
echo ""
echo "Credentials saved to: /tmp/ecr-readonly-credentials.txt"
echo ""
echo "Access Key ID: ${ACCESS_KEY_ID}"
echo "Secret Access Key: ${SECRET_ACCESS_KEY}"
echo ""
echo "IMPORTANT: Save these credentials securely. The secret access key cannot be retrieved again."
echo ""
echo "To delete this user and clean up:"
echo "  aws iam detach-user-policy --user-name ${IAM_USERNAME} --policy-arn ${POLICY_ARN}"
echo "  aws iam delete-access-key --user-name ${IAM_USERNAME} --access-key-id ${ACCESS_KEY_ID}"
echo "  aws iam delete-user --user-name ${IAM_USERNAME}"
echo "  aws iam delete-policy --policy-arn ${POLICY_ARN}"