FROM UBUNTU:latest

RUN apt-get update && apt-get install -y\
docker.io\
awscli\
rm -rf /var/lib/lists/*

WORKDIR app

COPY deployer.sh /app/deployer.sh

chmod +x deployer.sh

ENV = "staging"

CMD["./deployer.sh","-h"]

