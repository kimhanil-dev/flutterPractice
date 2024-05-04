FROM ubuntu:18.04

# Prerequisites
RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget

RUN apt-get update -y && sudo apt-get upgrade -y;

RUN apt-get install -y curl git unzip xz-utils zip libglu1-mesa

RUN apt-get install \
libc6:i386 libncurses5:i386 \
libstdc++6:i386 lib32z1 \
libbz2-1.0:i386

# Set up new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/developer/flutter/bin"

# Run basic check to download Dark SDK
RUN flutter doctor