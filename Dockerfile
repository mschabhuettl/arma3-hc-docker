FROM ubuntu:latest

# Set up apt and prepare the environment
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository multiverse \
    && dpkg --add-architecture i386 \
    && apt-get update

# Install steamcmd
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y steamcmd && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections

# Set working directory
WORKDIR /opt/arma3

# Copy necessary scripts
ADD install_arma3.txt install_arma3.txt
ADD start.sh start.sh

# Ensure scripts are executable
RUN chmod +x start.sh

# Install Arma 3 and launch the client
ENTRYPOINT ["/bin/bash", "start.sh"]

# Additional arguments for arma3server (such as -mod) can be passed as arguments
CMD []
