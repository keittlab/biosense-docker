# Use the official Debian stable slim image
FROM debian:stable-slim

# Define build-time variables
ARG RASPBIAN_DIR_DATE="2020-02-14"
ARG RASPBIAN_IMAGE_DATE="2020-02-13"
ARG HOSTNAME="keittlabsens"

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
    xz-utils \
    zip \
    bzip2 \
    && rm -rf /var/lib/apt/lists/*

# Create a new user 'agent' and set a password
RUN useradd -m agent && echo "agent:password" | chpasswd

# Add the new user to the sudo group
RUN usermod -aG sudo agent

# Allow members of the sudo group to execute any command without a password
RUN echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user and set the working directory
USER agent
WORKDIR /home/agent

# Define environment variables for the image download
ENV RASPBIAN_IMAGE="${RASPBIAN_IMAGE_DATE}-raspbian-buster-lite.zip"
ENV RASPBIAN_SHA256="${RASPBIAN_IMAGE_DATE}-raspbian-buster-lite.zip.sha256"
ENV RASPBIAN_BASE_URL="https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-${RASPBIAN_DIR_DATE}"

# Download the image and checksum file
RUN sudo curl -O ${RASPBIAN_BASE_URL}/${RASPBIAN_IMAGE}
RUN sudo curl -O ${RASPBIAN_BASE_URL}/${RASPBIAN_SHA256}

# Debugging: Print the contents of the checksum file to ensure it is correct
RUN cat ${RASPBIAN_SHA256}

# Verify the checksum using awk
RUN CHECKSUM=$(awk '{ print $1 }' ${RASPBIAN_SHA256}) && \
    echo "$CHECKSUM ${RASPBIAN_IMAGE}" > checksum.txt && \
    cat checksum.txt && \
    sha256sum -c checksum.txt

# Unzip the image
RUN sudo unzip ${RASPBIAN_IMAGE} -d /home/agent

# Install sdm utility
RUN sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | sudo bash

RUN sudo sdm --customize --expand-root --host ${HOSTNAME} --enable-ssh --autologin


# Example command to run after verification (modify as needed)
CMD ["bash"]
