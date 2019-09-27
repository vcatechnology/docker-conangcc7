FROM ubuntu:bionic

LABEL maintainer="Husam Hebaishi <husam.hebaishi@vcatechnology.com>"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
       autoconf-archive \
       binutils \
       ca-certificates \
       cmake \
       curl \
       dh-autoreconf \
       g++ \
       gcc \
       git \
       graphviz \
       less \
       libdbus-1-dev \
       libdbus-glib-1-dev \
       libnm-dev \
       libudev-dev \
       locales \
       ninja-build \
       python3 \
       python3-pip \
       python3-scp \
       python3-setuptools \
       python3-networkx \
       patchelf \
       ssh \
       sudo \
       tzdata \
       wget \
       xz-utils \
    && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 100 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 100 \
    && pip3 install -q --no-cache-dir conan conan-package-tools --upgrade \
    && conan profile new default --detect \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" >> /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y --no-install-recommends yarn \
    && yarn global add parcel-bundler@1.12.3 \
    && groupadd 1001 -g 1001 \
    && groupadd 1000 -g 1000 \
    && groupadd 2000 -g 2000 \
    && groupadd 999 -g 999 \
    && useradd -ms /bin/bash conan -g 1001 -G 1000,2000,999 \
    && printf "conan:conan" | chpasswd \
    && adduser conan sudo \
    && printf "conan ALL= NOPASSWD: ALL\\n" >> /etc/sudoers

USER conan
WORKDIR /home/conan
