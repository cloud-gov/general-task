# VERSION         0.1.0
# DOCKER-VERSION  1.9.1
# DESCRIPTION:    Concourse Task Image
# TO_BUILD:       docker build -t local/task .
# TO_RUN:         docker run local/task echo "Hello World!"
ARG base_image

FROM ${base_image}

# Copy local project directories to container image
COPY . /opt/concourse-ci/task

# Configure readline to fix issues with bracketed paste mode in SSH
COPY .inputrc /root/.inputrc

# Set current working directory for executed scripts
WORKDIR /opt/concourse-ci/task

#reduce warnings during build and accept default answers for packages
ARG DEBIAN_FRONTEND=noninteractive

# Use fips endpoints when avaiable when using the AWS CLI
ENV AWS_USE_FIPS_ENDPOINT true

# Use a custom build script instead of messy chained together RUN
# or multiple RUN statements that add bloat to the image
# AND Run tests on the Docker build
RUN /opt/concourse-ci/task/scripts/build.sh && /opt/concourse-ci/task/scripts/test.sh
