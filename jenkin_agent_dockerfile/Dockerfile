# Start from the official Jenkins inbound agent image
FROM jenkins/inbound-agent:latest

USER root

# Install dependencies (curl, apt-transport-https, etc.)
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg lsb-release

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
      https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# Install Go
RUN curl -fsSL https://go.dev/dl/go1.23.3.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    rm /tmp/go.tar.gz

# Set environment variables for Go
ENV GOPATH=/go
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Switch back to Jenkins user
USER root

# ----------------------------------------------------------
# NOTE:
# To allow this container to run Docker commands, mount the
# host Docker socket:
#     -v /var/run/docker.sock:/var/run/docker.sock
#
# Alternatively, if you need remote Docker access, you must
# expose the Docker daemon on the insecure TCP port 2375:
#     Edit /etc/docker/daemon.json and add:
#         { "hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"] }
#     Then restart Docker with:
#         sudo systemctl restart docker
#
# ⚠️ Be careful: exposing port 2375 is insecure and should
# only be used in trusted environments.
# ----------------------------------------------------------


