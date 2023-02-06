FROM 18fgsa/s3-resource-simple:latest

# Copy local project directories to container image
COPY . /opt/concourse-ci/task

# Set current working directory for executed scripts
WORKDIR /opt/concourse-ci/task

ARG TOKEN

# Use a custom build script instead of messy chained together RUN
# or multiple RUN statements that add bloat to the image
RUN /opt/concourse-ci/task/scripts/build.sh

# Run tests on the Docker build
RUN /opt/concourse-ci/task/scripts/test.sh
