# Use the official Debian stable slim image
FROM debian:stable-slim

# Make sure we're up to date
RUN apt-get update && apt-get -y full-upgrade

# Install necessary packages
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    unzip \
    fdisk \
    dosfstools \
    rsync \
    parted \
    kpartx \
    qemu-utils \
    qemu-user-static \
    qemu-system-arm \
    qemu-efi-aarch64 \
    ipxe-qemu \
    qemu-efi-arm \
    qemu-system-gui \
    systemd-container \
    binfmt-support \
    util-linux \
    wireguard \
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

COPY sdm-biosense-setup-plugin /usr/local/sdm/local-plugins
RUN sudo chmod +x /usr/local/sdm/local-plugins/sdm-biosense-setup-plugin

# Example command to run after verification (modify as needed)
CMD ["bash"]
