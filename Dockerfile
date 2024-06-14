# Use the official Debian stable slim image
FROM debian:stable-slim

# Make sure we're up to date
RUN apt-get update && apt-get -y full-upgrade

# Install necessary packages
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    unzip \
    fdisk \
    dosfstools \
    rsync \
    parted \
    kpartx \
    qemu-user-static \
    systemd-container \
    binfmt-support \
    xz-utils \
    zip \
    bzip2 \
    file \
    less \
    && rm -rf /var/lib/apt/lists/*

# Create a new user 'agent' and set a password
RUN useradd -m agent && echo "agent:agent" | chpasswd

# Add the new user to the sudo group
RUN usermod -aG sudo agent

# Allow members of the sudo group to execute any command without a password
RUN echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user and set the working directory
USER agent
WORKDIR /home/agent

RUN mkdir /home/agent/hostdir

# Install sdm utility
RUN sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | sudo bash

#RUN sudo sdm --customize --hostname ${HOSTNAME} "${RASPBIAN_IMAGE_DATE}-raspbian-buster-lite.img"

# Example command to run after verification (modify as needed)
CMD ["bash"]
