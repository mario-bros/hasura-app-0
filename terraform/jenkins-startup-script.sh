#Bootstrap Jenkins installation and start  
#!/bin/bash #specifies the interpreter

# sudo apt-get install -y git maven
# wget https://get.jenkins.io/war-stable/2.401.3/jenkins.war 
# java -jar jenkins.war

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install openjdk-17-jdk openjdk-17-jre -y
sudo apt-get install jenkins
