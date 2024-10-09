FROM ubuntu:latest

# Install dependencies and Docker
RUN apt-get update && \
    apt-get install -y docker.io curl unzip && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI using the official installation script
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

WORKDIR /app

COPY deployer.sh /app/deployer.sh

ENV ENV=staging

RUN chmod +x /app/deployer.sh

ENTRYPOINT ["/app/deployer.sh"]
CMD ["-h"]

