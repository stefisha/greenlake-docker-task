# Pull base image
FROM ubuntu:latest

################################
# Set build version
################################

RUN if [[ uname -m == "x86_64"]] ; then ARCH="amd64"; elif [[ uname -m == "aarch64"]]; then ARCH="arm64"; else echo "unknown arch for this image" exit 1; fi

RUN \
# Update
apt-get update -y && \
# Install Unzip
apt-get install unzip -y && \
# need wget
apt-get install wget -y && \
# vim
apt-get install vim -y && \
# curl
apt-get install curl -y && \
# git
apt-get install git -y

################################
# Create non-root user
################################

# Create non-root user "greenlake"
RUN useradd -ms /bin/bash greenlake
# Define home dir
WORKDIR /home/greenlake
# Set ownership
RUN chown -R greenlake:greenlake /home/greenlake

################################
# Install Terraform
################################

# Download terraform for linux
RUN \
wget https://releases.hashicorp.com/terraform/1.5.2/terraform_1.5.2_linux_${ARCH}.zip \
# Unzip
unzip terraform_1.5.2_linux_${ARCH}.zip \
# Move to local bin
mv terraform /usr/local/bin/ \
# Check that it's installed
terraform --version \
# Delete zip file
rm terraform_1.5.2_linux_${ARCH}.zip

################################
# Install python
################################

RUN apt-get install -y python3-pip
RUN ln -s /usr/bin/python3 python
# upgrade pip
RUN pip3 install --upgrade pip
# check python version
RUN python3 -V
# check pip version
RUN pip --version

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

ENV DEBIAN_FRONTEND=noninteractive

RUN \
# kerberos
#apt install krb5-user -y && \ 
# pywinrm to connect remote
pip3 install pywinrm && \
# ansible
pip3 install ansible

################################
# Setup Kubernetes 
################################

# Get kubernetes
RUN curl -sSL "http://storage.googleapis.com/kubernetes-release/release/v1.2.0/bin/linux/${ARCH}/kubectl" > /usr/bin/kubectl 
# Setup simple cluster configuration
#RUN kubectl config set-cluster test-doc --server=http://localhost:8080 && \
#kubectl config set-context test-doc --cluster=test-doc && \
#kubectl config use-context test-doc

# switch to non-root user
USER greenlake
# Set command when container starts
CMD ["/bin/bash"]