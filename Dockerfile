FROM ubuntu:latest

# Set up apt and prepare the environment
RUN apt-get update && apt-get install -y \
    software-properties-common \
    uuid-runtime \
    locales \
    && add-apt-repository multiverse \
    && dpkg --add-architecture i386 \
    && apt-get update

# Configure locales to avoid locale warnings
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Pre-configure debconf to accept the Steam License Agreement
RUN echo "steam steam/question select I AGREE" | debconf-set-selections && \
    echo "steam steam/license note ''" | debconf-set-selections

# Install steamcmd
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y steamcmd && \
    mkdir -p /usr/games && \
    ln -s $(which steamcmd) /usr/games/steamcmd

# Ensure the installation directory exists
RUN mkdir -p /arma3

# Set working directory
WORKDIR /arma3

# Copy necessary scripts
ADD install_arma3.txt install_arma3.txt
ADD start.sh start.sh

# Ensure scripts are executable
RUN chmod +x start.sh

# Install Arma 3 and launch the client
ENTRYPOINT ["/bin/bash", "start.sh"]

# Additional arguments for arma3server (such as -mod) can be passed as arguments
CMD []
