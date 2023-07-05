# Pull base image.
FROM ubuntu:latest

RUN \
# Update
apt-get update -y && \
# Install Unzip
apt-get install unzip -y && \
# need wget
apt-get install wget -y && \
# vim
apt-get install vim -y

################################
# Create user for container
################################

# Create user 'greenlake'
RUN useradd -ms /bin/bash greenlake
# Define home dir
USER greenlake
WORKDIR /home/greenlake

################################
# Install Terraform
################################

# Download terraform for linux
RUN wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip

# Unzip
RUN unzip terraform_0.11.11_linux_amd64.zip

# Move to local bin
RUN mv terraform /usr/local/bin/
# Check that it's installed
RUN terraform --version 
# Delete zip file
RUN rm terraform_0.11.11_linux_amd64.zip

################################
# Install python
################################

RUN apt-get install -y python3-pip
#RUN ln -s /usr/bin/python3 python
RUN pip3 install --upgrade pip
RUN python3 -V
RUN pip --version

################################
# Install AWS CLI
################################
RUN pip install awscli --upgrade --user

# add aws cli location to path
ENV PATH=~/.local/bin:$PATH

# Adds local templates directory and contents in /usr/local/terrafrom-templates
#ADD templates /usr/local/bin/templates

RUN mkdir ~/.aws && touch ~/.aws/credentials

################################
# Install Terraform
################################

ENV DEBIAN_FRONTEND=noninteractive

RUN \
# kerberos
apt install krb5-user -y && \ 
# pywinrm to connect remote
pip3 install pywinrm && \
# ansible
pip3 install ansible