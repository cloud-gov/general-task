FROM 18fgsa/oracle-client:latest
LABEL MAINTAINERS="devops@gsa.gov"

ENV ACCEPT_EULA Y

RUN yum install -y wget && \
    wget -O /etc/yum.repos.d/cloudfoundry-cli.repo https://packages.cloudfoundry.org/fedora/cloudfoundry-cli.repo && \
    wget -O /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/7/prod.repo

RUN yum install -y --nogpgcheck postgresql \
    mysql \
    mssql-tools \
    unixODBC-devel \
    cf-cli \
    jq

# so we can access the mssql clients.
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
