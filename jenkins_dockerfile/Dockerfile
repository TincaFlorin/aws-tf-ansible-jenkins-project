FROM jenkins/jenkins:2.528.1-jdk21
USER root
RUN apt-get update && apt-get install -y lsb-release ca-certificates curl && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/* \
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow json-path-api"


# docker run --name jenkins --restart=on-failure --detach \
#   --publish 8080:8080 --publish 50000:50000 \
#   --volume jenkins-data:/var/jenkins_home \
#   --volume jenkins-docker-certs:/certs/client:ro \
#   --volume /var/run/docker.sock:/var/run/docker.sock \
#   --group-add $(getent group docker | cut -d: -f3) \
#   tincadocker/jenkins

# SPECIFY THE JENKINS_HOST when configuring Jenkins agents to connect back to the master
# e.g., http://your-jenkins-domain-or-ip:8080
