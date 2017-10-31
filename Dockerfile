FROM ubuntu

# Set up apt.
RUN apt-get update
RUN apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository multiverse
RUN dpkg --add-architecture i386

# Install steamcmd.
RUN apt-get update
RUN yes 2 | apt-get install -y steamcmd

# We don't install Arma 3 as part of the docker build because it can't be
# installed with anonymous login, and using --build-arg would make the
# credentials visible in the build history.

WORKDIR /opt/arma3

ADD install_arma3.txt install_arma3.txt
ADD start.sh start.sh

# Install Arma 3 and launch the client.
CMD ["/bin/bash", "start.sh"]
