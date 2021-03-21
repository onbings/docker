FROM debian:stretch
 
WORKDIR /
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y software-properties-common \
    && rm -rf /var/lib/apt/lists/*
  
# Install required repositories
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates gnupg2 wget  && \
#    add-apt-repository 'deb https://releases.jfrog.io/artifactory/jfrog-debs xenial contrib' && \
#    wget -qO - http://10.143.137.48/evs/repo/conf/gpg.key | apt-key add - && \
    apt-get clean && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
	alsa-utils \
	ant \
	apt-file \ 
	at-spi2-core \
	autoconf \ 
    automake \
	autopoint \
	bison \
    build-essential \
    byacc \
	bzip2 \
	curl \
	dos2unix \
    flex \
    g++ \
    gcc \
    gdb \
    gdbserver \
	gettext \
    git \
	gperf \
    lcov \
	libclang-dev \
	libcurl4-openssl-dev \
	libdbus-1-dev \
	libfontconfig1-dev \
	libfreetype6-dev \
	libgles2-mesa-dev \
	libglu1-mesa-dev \
	libgstreamer-plugins-base1.0-dev \
	liblua5.2-dev \
	libmbedtls-dev \
	libmpg123-dev \
	libpulse-dev \
	libsm-dev \
	libssl-dev \
	libtool \
	libx11-dev \
	libx11-xcb-dev \
	libxext-dev \
	libxfixes-dev \
	libxi-dev \
	libxrender-dev \
	libxcb1-dev \
	libxcb-composite0-dev \
	libxcb-glx0-dev \
	libxcb-keysyms1-dev \
	libxcb-image0-dev \
	libxcb-shm0-dev \
	libxcb-icccm4-dev \
	libxcb-sync-dev \
	libxcb-xfixes0-dev \
	libxcb-shape0-dev \
	libxcb-randr0-dev \
	libxcb-render-util0-dev \
	libxcb-util0-dev \
	libxcb-xinerama0-dev \
	libxcb-xkb-dev \
	libxcb-xv0-dev \
	libxcomposite-dev \
	libxkbcommon-dev \
	libxkbcommon-x11-dev \	
	lua5.2 \
	meson \
	m4 \
	mesa-common-dev \
    nano \
    ninja-build \
	ntp \
	openjdk-8-jdk \
	openjdk-8-jre \
    openssh-client \
    openssh-server \
    patch \
	pkg-config \
	protobuf-compiler \
	pulseaudio \
    python \
    python3-dev \
    python3-pip \
    ragel \
    rsync \
    sudo \
#	wayland-protocols \
	wget \
    xorg-dev \
    unzip \
	zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*



# Install specific Nvidia toolkit
#RUN apt-get update && apt-get install -y --allow-unauthenticated \
#    nvidia-installer-4.9.35-dyvi \
#    kmod \
#    && /opt/nvidia/NVIDIA-Linux-x86_64-*-custom.run -s --no-kernel-module \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/* \
#    && rm -rf /opt/nvidia/NVIDIA-Linux-x86_64-*
 
RUN pip3 install setuptools 
RUN pip3 install wheel 
RUN pip3 install meson

#for apt-file: to be removed later
RUN apt update 
	
# configure SSH
RUN mkdir /var/run/sshd
RUN echo 'root:a' | chpasswd
RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
 
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
 
EXPOSE 22
 
# Add variable to the "default" environment so that user login through ssh will also have the proper variables
RUN env | egrep -v "^(HOME=|USER=|MAIL=|LC_ALL=|LS_COLORS=|LANG=|HOSTNAME=|PWD=|TERM=|SHLVL=|LANGUAGE=|_=)" >> /etc/environment
 
#add user
RUN useradd -rm -d /home/bha -s /bin/bash -g root -G sudo -u 1001 bha -p "$(openssl passwd -1 a)"
USER bha
WORKDIR /home/bha
RUN mkdir -p /home/bha/.local/bin

ENV PATH="/home/bha/.local/bin:/home/bha/onbings/third.wsl2/nasm-2.15.05/build/install/bin:/home/bha/onbings/third.wsl2/qt5/build/install/bin:${PATH}"
ENV QTDIR=/home/bha/onbings/third.wsl2/qt5/build/install/mkspecs/linux-g++
ENV LD_LIBRARY_PATH="/home/bha/.local/lib:/home/bha/onbings/third.wsl2/x264/build/install/lib:/home/bha/onbings/third.wsl2/ffmpeg/build/install/lib:/home/bha/onbings/third.wsl2/qt5/build/install/lib:/home/bha/onbings/third.wsl2/icu/source/build/install/lib:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="/home/bha/onbings/third.wsl2/x264/build/install/lib/pkgconfig:/home/bha/onbings/third.wsl2/ffmpeg/build/install/lib/pkgconfig:/home/bha/onbings/third.wsl2/qt5/build/install/lib/pkgconfig:/home/bha/onbings/third.wsl2/icu/source/build/install/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:${PKG_CONFIG_PATH}"

USER root
ENV PATH="/home/bha/.local/bin:/home/bha/onbings/third.wsl2/nasm-2.15.05/build/install/bin:/home/bha/onbings/third.wsl2/qt5/build/install/bin:${PATH}"
ENV QTDIR=/home/bha/onbings/third.wsl2/qt5/build/install/mkspecs/linux-g++
ENV LD_LIBRARY_PATH="/home/bha/.local/lib:/home/bha/onbings/third.wsl2/x264/build/install/lib:/home/bha/onbings/third.wsl2/ffmpeg/build/install/lib:/home/bha/onbings/third.wsl2/qt5/build/install/lib:/home/bha/onbings/third.wsl2/icu/source/build/install/lib:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="/home/bha/onbings/third.wsl2/x264/build/install/lib/pkgconfig:/home/bha/onbings/third.wsl2/ffmpeg/build/install/lib/pkgconfig:/home/bha/onbings/third.wsl2/qt5/build/install/lib/pkgconfig:/home/bha/onbings/third.wsl2/icu/source/build/install/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:${PKG_CONFIG_PATH}"


# Install CMake
RUN wget -qO- "https://cmake.org/files/v3.18/cmake-3.18.4-Linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /home/bha/.local
#ENV PATH="/usr/local/cmake/bin:${PATH}:/usr/local/cuda-9.1/bin"
 
# Install googletest
#RUN git clone https://github.com/google/googletest.git /googletest \
#    && mkdir -p /googletest/build \
#    && cd /googletest/build \
#    && cmake .. && cmake --build ./ && cmake --install ./ --prefix /home/bha/.local/lib/googletest \
#    && cd / && rm -rf /googletest
# 
#ENV GTEST_ROOT=/home/bha/.local/lib/googletest

#CMD service ssh start && /bin/bash
