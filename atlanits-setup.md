# Atlantis + AWS Terraform GitHub Integration Setup Guide
# 1. Launch EC2 Instance (Amazon Linux 2023 or Amazon Linux 2)  
Use an Amazon Linux 2 or Ubuntu AMI.  
Optional IAM Role: Attach policies such as AmazonS3FullAccess, AmazonEC2FullAccess, etc., to enable Terraform to manage AWS infrastructure securely.  

# 2. How AWS, EC2, Terraform, and Atlantis Work Together  
✅ EC2 Instance: Acts as the server running Atlantis, a tool that automates Terraform operations triggered by GitHub pull requests.  
✅ Terraform: Infrastructure-as-Code tool installed or used on the EC2 instance via Docker to provision and manage AWS resources.  
✅ IAM Role / Credentials: The EC2 instance either assumes an IAM role with sufficient AWS permissions or uses AWS credentials to authenticate Terraform API calls to AWS services.  
✅ Atlantis: Listens for GitHub webhook events (like pull requests), runs Terraform commands (plan, apply) on the EC2 instance, and posts results back to GitHub PRs.  
✅ In short:  
Terraform on the EC2 instance uses AWS credentials or roles to directly manage your AWS infrastructure, while Atlantis orchestrates Terraform runs based on GitHub PR activity.  

# 3. Install Dependencies (Docker & Git)  
For Amazon Linux 2:  
✅ Update packages  
```bash
        sudo yum update -y
```
✅ Install Docker 
```bash
        sudo amazon-linux-extras install docker -y  
        sudo service docker start  
        sudo usermod -a -G docker ec2-user
```  
✅ Install Git  
```bash
        sudo yum install git -y
```
✅ Verify installations  
```bash
        docker version  
        git --version  
```
✅ For Amazon Linux 2023 (amazon-linux-extras not available):  
```bash
        sudo dnf update -y  
        sudo dnf install docker -y  
        sudo systemctl enable --now docker  
        sudo usermod -aG docker ec2-user  

        sudo dnf install git -y  
```
# 4. Create a GitHub Webhook Secret for Atlantis  
What is it for?  
When GitHub sends webhook events (like pull requests or comments), it signs the payload with this secret. Atlantis verifies this signature to confirm the webhook is authentic.  

Steps:  
✅ Generate a webhook secret token (40-character hex string) in EC2 instance    
```bash
        openssl rand -hex 20
```
✅ In your GitHub repository, go to:  
```bash
        Settings → Webhooks → Add webhook  
        Payload URL: http://<EC2-Public-IP>:4141/events  
        Secret: your-generated-secret  
        Events: Select "Pull requests" and "Issue comments"  
```
# 5. Create a GitHub Personal Access Token (PAT)  
Generate a PAT with repo permissions for your GitHub user.  
This token allows Atlantis to interact with GitHub (e.g., post comments on PRs).  

# 6. Run the Atlantis Docker Container on EC2  
```bash
        docker run -d --name atlantis \  
          -p 4141:4141 \  
          -e ATLANTIS_GH_USER=your-github-username \  
          -e ATLANTIS_GH_TOKEN=your-github-pat-token \  
          -e ATLANTIS_REPO_WHITELIST=github.com/your-org-or-username/* \  
          -e ATLANTIS_GH_WEBHOOK_SECRET=your-webhook-secret \  
          -e ATLANTIS_LOG_LEVEL=info \  
          -v /home/ec2-user/.aws:/root/.aws:ro \  
          runatlantis/atlantis  
```
Replace placeholders (your-github-username, your-github-pat-token, your-webhook-secret) accordingly.  
Mount AWS credentials stored on the EC2 instance in /home/ec2-user/.aws to allow Terraform to authenticate AWS API calls.

# 7. Accessing Atlantis Web UI  
Atlantis provides a simple web interface where you can see the status of Terraform runs triggered by your GitHub pull requests.  

✅ Steps to check Atlantis in your browser:  
&nbsp;&nbsp;Open your browser and navigate to: http://<EC2-Public-IP>:4141  
&nbsp;&nbsp;Replace <EC2-Public-IP> with your actual EC2 instance public IP address or DNS name.  
&nbsp;&nbsp;&nbsp;&nbsp;Expected page:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;You should see the Atlantis homepage or a simple interface that confirms the service is running.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If you see a 404 or connection error, check:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The EC2 instance is running.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Security groups allow inbound traffic on port 4141.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Docker container for Atlantis is running (docker ps).  

# 8. Testing Atlantis webhook:  
When you open or comment on a pull request in your configured GitHub repo, Atlantis listens to the webhook and triggers Terraform plan/apply automatically.  

The results (plan or apply output) appear as comments inside your GitHub PR.  

