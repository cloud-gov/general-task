FROM ubuntu:18.04
LABEL MAINTAINERS="devops@gsa.gov"

ENV ACCEPT_EULA Y

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl gnupg && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | tee /etc/apt/sources.list.d/msprod.list && \
    apt-get update

RUN apt-get install -y postgresql-client \
    mysql-client \
    mssql-tools 
