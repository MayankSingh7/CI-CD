Jenkins Installation Guide on Amazon Linux 2 and Amazon Linux 2023

✅ Update packages  
```bash
        sudo dnf update -y -> For Amazon Linux 2023
        sudo yum update -y -> Amazon Linux 2
```
✅ Install Java 17 (Amazon Corretto)  
```bash
        sudo dnf install java-17-amazon-corretto -y -> For Amazon Linux 2023
        sudo yum install java-11-amazon-corretto -y -> Amazon Linux 2
        java -version
```
✅ Add Jenkins Repository and Key
```bash
        sudo curl --silent --location https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key | sudo tee /etc/pki/rpm-gpg/jenkins.io.key > /dev/null

        sudo tee /etc/yum.repos.d/jenkins.repo > /dev/null <<EOF
        [jenkins]
        name=Jenkins-stable
        baseurl=https://pkg.jenkins.io/redhat-stable
        gpgcheck=1
        gpgkey=file:///etc/pki/rpm-gpg/jenkins.io.key
        EOF
```
✅ Install Jenkins
```bash
      sudo dnf install jenkins -y -> For Amazon Linux 2023
      sudo yum install jenkins -y -> Amazon Linux 2
```
✅ Enable and Start Jenkins
```bash
      sudo systemctl enable jenkins
      sudo systemctl start jenkins
```
Open port 8080 -> Source: 0.0.0.0/0 (for public access) or your IP for restricted access.
Jenkins should be accessible via:http://<ec2-public-ip>:8080
Retrieve initial admin password:
```bash
      sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
