# Flask + Docker + Terraform + Jenkins CI/CD (sample)

## Overview
This repo contains:
- Simple Flask app
- Dockerfile to containerize app
- Terraform in `infra/` to create an EC2 that runs the Docker image
- Jenkinsfile to automate build -> push -> deploy

## Steps to use

1. Create GitHub repo and push these files.

2. Create Docker Hub repo (e.g. `yourdockerhubusername/flask-app`).

3. Create AWS key pair (or use an existing one). Note the key pair name.

4. Jenkins setup:
   - Ensure Jenkins agent has `docker`, `terraform`, `git` installed.
   - Add Jenkins credentials:
     - `dockerhub-creds` (Username with password) — DockerHub username / password or PAT
     - `aws-creds` (Username with password) — AWS Access Key ID as username, AWS Secret Access Key as password
   - Create a Pipeline job that pulls the `Jenkinsfile` from this repository
   - Set `DOCKER_REPO` and credential IDs in the Jenkinsfile or set them as job-level environment variables if you prefer.

5. Terraform variables:
   - Provide `key_name` when running (Jenkins will use default variable file or you can add var in the pipeline).
   - Jenkinsfile passes `docker_image` automatically.

6. Run pipeline:
   - On each Git push, Jenkins will:
     - Build Docker image
     - Push to Docker Hub (tagged with BUILDNUMBER-SHORTSHA and `latest`)
     - Run Terraform (plan & apply) that updates EC2 `user_data` to pull the new image

## Notes & recommendations
- For production, use a remote Terraform state backend (S3 + DynamoDB locks).
- Prefer IAM roles, least privilege policies for production.
- Consider using ECR for private Docker images and using instance IAM role with ECR permissions instead of DockerHub credentials.
