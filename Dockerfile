FROM ubuntu:bionic

# Add required packages for TFE worker (except AWS CLI)
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  sudo unzip daemontools git-core ssh wget curl psmisc iproute2 openssh-client redis-tools netcat-openbsd ca-certificates

# Add AWS CLI V2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# Add packages not included in default image
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  python3.8 python3-pip

# Python 2-> Redirect
RUN ln -s /usr/bin/python3 /usr/bin/python

# Pip Packages
RUN python3 -m pip install --upgrade boto3 requests-aws4auth Jinja2 urllib3

# Startup Script
ADD files/init_custom_worker.sh /usr/local/bin/init_custom_worker.sh
