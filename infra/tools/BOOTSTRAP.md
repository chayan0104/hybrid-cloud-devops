# Bootstrap: Initialize Terraform & Vault

**Time to complete:** 10-15 minutes

Initialize the Terraform state backend and configure Vault for secrets management. Must be done **first** before any infrastructure provisioning.

## ⚠️ Important

This is a **one-time setup**. After initial bootstrap, skip this step for subsequent deployments.

## ✅ Prerequisites

```bash
# Required tools
terraform version     # 1.5+
aws --version        # AWS CLI 2.0+
vault version        # Vault 1.14+ (optional)
jq --version         # JSON processor (optional)

# AWS credentials configured
aws sts get-caller-identity
# Should show your AWS account ID

# AWS permissions needed:
# - S3 (create bucket for terraform state)
# - DynamoDB (state locking)
# - IAM (roles and policies)
```

## 🚀 Step-by-Step Bootstrap

### Step 1: Prepare Bootstrap Variables (2 min)

Create a file: `infra/terraform/bootstrap-state/bootstrap.auto.tfvars`

```hcl
# Region for S3 bucket and DynamoDB
aws_region = "us-east-1"

# S3 bucket name (must be globally unique)
terraform_state_bucket = "my-org-terraform-state-2026"

# Project name for tagging
project_name = "hybrid-cloud-devops"

# Environment
environment = "prod"

# Enable versioning and encryption
enable_versioning = true
enable_encryption = true
```

**Note:** S3 bucket names must be globally unique. Add timestamp or org name.

### Step 2: Initialize Terraform (3 min)

```bash
cd infra/terraform/bootstrap-state

# Initialize Terraform
terraform init

# Plan the bootstrap (see what will be created)
terraform plan

# Expected output:
# Plan: 2 to add, 0 to change, 0 to destroy.
#   + aws_s3_bucket.terraform_state
#   + aws_dynamodb_table.terraform_locks
```

### Step 3: Apply Bootstrap (5 min)

```bash
# Create S3 bucket and DynamoDB table
terraform apply

# Confirm: type 'yes'

# Wait for creation (~2-3 minutes)
```

**Expected output:**
```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:
s3_bucket_name = "my-org-terraform-state-2026"
dynamodb_table_name = "terraform-locks"
```

### Step 4: Save Outputs (1 min)

```bash
# Save bootstrap outputs
terraform output -json > bootstrap-outputs.json

# View key values
terraform output s3_bucket_name
terraform output dynamodb_table_name
```

### Step 5: Configure Production Terraform (2 min)

Create `infra/terraform/prod/backend-config.hcl`:

```hcl
# Get these from bootstrap outputs above
bucket         = "my-org-terraform-state-2026"
key            = "prod/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks"
encrypt        = true
```

Similarly for `infra/terraform/perf-prod/backend-config.hcl`:

```hcl
bucket         = "my-org-terraform-state-2026"
key            = "perf-prod/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks"
encrypt        = true
```

## 🔐 Step 6: Initialize Vault (5 min)

### Option A: Using Existing Vault Instance

If your organization has Vault already running:

```bash
# Set Vault address
export VAULT_ADDR="https://vault.company.com:8200"
export VAULT_TOKEN="<your-token>"

# Verify connection
vault status

# Skip to: Configure Jenkins AppRole
```

### Option B: Local Vault for Development

```bash
# Install Vault locally (if not already)
# macOS:
brew install vault

# Linux/Windows: Download from https://www.vaultproject.io/downloads

# Start Vault in dev mode (NOT for production)
vault server -dev

# In another terminal, configure
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="<shown in startup output>"
```

### Step 7: Create AppRole for Jenkins (3 min)

```bash
cd infra/vault

# Enable AppRole auth method
vault auth enable approle

# Create role
vault write auth/approle/role/jenkins-ci \
  token_num_uses=0 \
  token_ttl=1h \
  secret_id_ttl=24h

# Get role ID
ROLE_ID=$(vault read -field=role_id auth/approle/role/jenkins-ci/role-id)
echo "ROLE_ID: $ROLE_ID"

# Generate secret ID
SECRET_ID=$(vault write -field=secret_id -f auth/approle/role/jenkins-ci/secret-id)
echo "SECRET_ID: $SECRET_ID"

# Save these (needed for Jenkins configuration)
cat > jenkins-approle.txt <<EOF
ROLE_ID=$ROLE_ID
SECRET_ID=$SECRET_ID
EOF

echo "✅ Saved to jenkins-approle.txt"
```

### Step 8: Create Secret Paths (3 min)

```bash
# Create secret paths structure
vault secrets enable -path=secret kv-v2

# Shared secrets (JFrog, registries)
vault kv put secret/shared/jfrog \
  username="jfrog-user" \
  password="jfrog-password"

vault kv put secret/shared/docker-registry \
  username="registry-user" \
  password="registry-password"

# UAT secrets
vault kv put secret/uat/app \
  db_host="postgres.company.com" \
  db_port="5432" \
  db_name="app_uat" \
  db_user="app_user" \
  db_password="secure-password" \
  api_key="uat-api-key"

# PROD secrets
vault kv put secret/prod/app \
  db_host="prod-rds.company.com" \
  db_port="5432" \
  db_name="app_prod" \
  db_user="app_user" \
  db_password="secure-prod-password" \
  api_key="prod-api-key"

# PERF-PROD secrets
vault kv put secret/perf-prod/app \
  db_host="perf-rds.company.com" \
  db_port="5432" \
  db_name="app_perf" \
  db_user="app_user" \
  db_password="secure-perf-password" \
  api_key="perf-api-key"
```

### Step 9: Apply Policies (2 min)

```bash
# Create Jenkins policy
vault policy write jenkins vault-policies.hcl

# Verify policy
vault policy read jenkins

# Bind AppRole to policy
vault write auth/approle/role/jenkins-ci/policies \
  policies="jenkins,default"
```

## ✅ Validation

### Verify Terraform State Backend

```bash
# Check S3 bucket exists and is encrypted
aws s3api head-bucket --bucket my-org-terraform-state-2026

# Check DynamoDB table
aws dynamodb describe-table --table-name terraform-locks
```

### Verify Vault Configuration

```bash
# Test AppRole login (simulating Jenkins)
ROLE_ID="<from-above>"
SECRET_ID="<from-above>"

vault write -field=token auth/approle/login \
  role_id=$ROLE_ID \
  secret_id=$SECRET_ID

# Should return a valid token
```

### Verify Secrets

```bash
# List secret paths
vault kv list secret/shared
vault kv list secret/uat
vault kv list secret/prod

# Read a secret
vault kv get secret/uat/app
```

## 🔒 Security Checklist

- [ ] S3 bucket has encryption enabled
- [ ] S3 bucket has versioning enabled
- [ ] S3 bucket is NOT public
- [ ] DynamoDB table has encryption enabled
- [ ] Terraform state files are encrypted at rest
- [ ] Vault is using HTTPS (not HTTP)
- [ ] Secrets are stored in Vault (not in code)
- [ ] AppRole credentials stored securely (e.g., Jenkins credentials store)
- [ ] IAM policies follow least-privilege principle

## 🚨 Troubleshooting

### S3 Bucket Already Exists

```bash
# Error: "The bucket already exists"
# Solution: Use a different bucket name
# Edit: infra/terraform/bootstrap-state/bootstrap.auto.tfvars
# Change: terraform_state_bucket = "my-org-terraform-state-2026-v2"

terraform apply
```

### Terraform State Locked

```bash
# Error: "Error releasing the state lock"
# Solution: Force unlock (use with caution)
terraform force-unlock <LOCK_ID>

# Then retry
terraform apply
```

### Vault Connection Failed

```bash
# Error: "Unable to authenticate to Vault"
# Check Vault is running and accessible
vault status

# Verify VAULT_ADDR
echo $VAULT_ADDR

# Test connectivity
curl -k $VAULT_ADDR/v1/sys/health
```

### AppRole Auth Not Working

```bash
# Verify role exists
vault list auth/approle/role

# Check role configuration
vault read auth/approle/role/jenkins-ci

# Regenerate secret ID
vault write -f auth/approle/role/jenkins-ci/secret-id
```

## 📝 Save These Values

After bootstrap, **save these credentials securely**:

```
Bootstrap Configuration
=======================
Date: 2026-06-03
Completed by: <your-name>

Terraform State Backend
- S3 Bucket: my-org-terraform-state-2026
- DynamoDB Table: terraform-locks
- Region: us-east-1

Vault Configuration
- Vault Address: https://vault.company.com:8200
- Vault Token: <saved-securely>

Jenkins AppRole
- Role ID: <saved-in-jenkins>
- Secret ID: <rotated-periodically>

⚠️ Store these in a secure location (1Password, HashiCorp Vault, AWS Secrets Manager)
```

## 🔄 Post-Bootstrap

After successful bootstrap:

1. **Next Step:** [TERRAFORM_PROVISIONING.md](TERRAFORM_PROVISIONING.md)
   - Provision AWS infrastructure (VPC, EC2, EKS, RDS)

2. **Configure Jenkins**
   - Add AppRole credentials to Jenkins
   - Enable Jenkins to access Vault
   - Store in Jenkins Credentials Store

3. **Team Onboarding**
   - Share Vault address with team
   - Grant appropriate Vault permissions
   - Document secret paths and rotation policy

## 📚 References

- [Terraform S3 Backend](https://www.terraform.io/language/settings/backends/s3)
- [Terraform State Locking](https://www.terraform.io/language/state/locking)
- [Vault AppRole Authentication](https://www.vaultproject.io/docs/auth/approle)
- [Vault Secrets Engines](https://www.vaultproject.io/docs/secrets)

---

**Bootstrap complete!** → [TERRAFORM_PROVISIONING.md](TERRAFORM_PROVISIONING.md)

**Issues?** → [TROUBLESHOOTING_TOOLS.md](TROUBLESHOOTING_TOOLS.md)
