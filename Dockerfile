# Pull base image
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y unzip wget vim curl git python3-pip ansible

################################
# Create non-root user
################################
# Create non-root user "greenlake"
RUN useradd -ms /bin/bash greenlake
# Define home dir
WORKDIR /home/greenlake
# Set ownership
RUN chown -R greenlake:greenlake /home/greenlake

# Terraform and kubectl
RUN if [ $(uname -m) = "x86_64" ]; then ARCH="amd64"; elif [ $(uname -m) = "aarch64" ]; then ARCH="arm64"; else echo "unknown arch for this image" && exit 1; fi \
    && wget https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && wget https://releases.hashicorp.com/terraform/1.5.2/terraform_1.5.2_linux_${ARCH}.zip \
    && unzip terraform_1.5.2_linux_${ARCH}.zip \
    && mv terraform kubectl /usr/local/bin/ \
    && rm terraform_1.5.2_linux_${ARCH}.zip

################################
# Install AWS CLI
################################

# install aws clu with pip
RUN pip install awscli --upgrade --user
# add aws cli location to path
ENV PATH=~/.local/bin:$PATH
# create fodler for storing credentials
RUN mkdir ~/.aws && touch ~/.aws/credentials

################################
# Install Ansible
################################

RUN \
# kerberos
apt install krb5-user -y && \ 
# pywinrm to connect remote
pip3 install pywinrm

################################
# Setup Kubernetes 
################################

# Setup simple cluster configuration
# RUN kubectl config set-cluster test-doc --server=http://localhost:8080 && \
# kubectl config set-context test-doc --cluster=test-doc && \
# kubectl config use-context test-doc

# Alternative, only for amd64
# RUN curl -LO "https://dl.k8s.io/release/v1.24.7/bin/linux/${ARCH}/kubectl" 
# RUN curl -LO "https://dl.k8s.io/v1.24.7/bin/linux/${ARCH}/kubectl.sha256"
# # check version
# RUN echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
# # add privelage
# RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# switch to non-root user
USER greenlake
# Set command when container starts
CMD ["/bin/bash"]