FROM ubuntu:xenial

LABEL maintainer="Luis Martinez de Bartolome <luism@jfrog.com>"

ENV DEBIAN_FRONTEND=noninteractive 

ENV PYENV_ROOT=/opt/pyenv \
    PATH=/opt/pyenv/shims:${PATH} \
    CXX=/usr/bin/g++ \
    CC=/usr/bin/gcc

RUN dpkg --add-architecture i386 \
    && echo "deb http://ppa.launchpad.net/jonathonf/gcc-7.2/ubuntu xenial main" > /etc/apt/sources.list.d/gcc.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4AB0F789CBA31744CC7DA76A8CF63AD3F06FC659 \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
       sudo=1.* \
       apt-transport-https \
       binutils=2.* \
       wget=1.* \
       git=1:2.* \
       libc6-dev-i386=2.* \
       linux-libc-dev:i386=4.* \
       g++-7-multilib=7.* \
       libgmp-dev=2:6.* \
       libmpfr-dev=3.* \
       libmpc-dev=1.* \
       libc6-dev=2.* \
       nasm=2.* \
       dh-autoreconf=11 \
       ninja-build=1.* \
       libffi-dev=3.* \
       libssl-dev=1.* \
       pkg-config=0.* \
       subversion=1.* \
       zlib1g-dev=1:1.* \
       libbz2-dev=1.* \
       libsqlite3-dev=3.* \
       libreadline-dev=6.* \
       xz-utils=5.* \
       curl=7.* \
       libncurses5-dev=6.* \
       libncursesw5-dev=6.* \
       liblzma-dev=5.* \
       ca-certificates \
       autoconf-archive \
       patchelf \ 
       gnupg2 \
       libdbus-1-dev \
       libdbus-glib-1-dev \
       libnm-dev \
       libudev-dev \
       graphviz

# Remove gcc 5 and cleanup
RUN sudo apt-get remove -y -qq gcc-5* \
       && sudo apt-get -y -qq autoremove 
       
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-7 100 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 100 

RUN rm -rf /var/lib/apt/lists/* \
    && wget --no-check-certificate --quiet https://cmake.org/files/v3.14/cmake-3.14.3-Linux-x86_64.tar.gz \
    && tar -xzf cmake-3.14.3-Linux-x86_64.tar.gz \
       --exclude=bin/cmake-gui \
       --exclude=doc/cmake \
       --exclude=share/cmake-3.12/Help \
    && cp -fR cmake-3.14.3-Linux-x86_64/* /usr \
    && rm -rf cmake-3.14.3-Linux-x86_64 \
    && rm cmake-3.14.3-Linux-x86_64.tar.gz 

RUN groupadd 1001 -g 1001 \
    && groupadd 1000 -g 1000 \
    && groupadd 2000 -g 2000 \
    && groupadd 999 -g 999 \
    && useradd -ms /bin/bash conan -g 1001 -G 1000,2000,999 \
    && printf "conan:conan" | chpasswd \
    && adduser conan sudo \
    && printf "conan ALL= NOPASSWD: ALL\\n" >> /etc/sudoers 

RUN wget --no-check-certificate --quiet -O /tmp/pyenv-installer https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer \
    && chmod +x /tmp/pyenv-installer \
    && /tmp/pyenv-installer \
    && rm /tmp/pyenv-installer \
    && update-alternatives --install /usr/bin/pyenv pyenv /opt/pyenv/bin/pyenv 100 \
    && PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.7.1 \
    && pyenv global 3.7.1 \
    && pip install -q --upgrade --no-cache-dir pip \
    && pip install -q --no-cache-dir conan conan-package-tools scp \
    && chown -R conan:1001 /opt/pyenv \
    # remove all __pycache__ directories created by pyenv
    && find /opt/pyenv -iname __pycache__ -print0 | xargs -0 rm -rf \
    && update-alternatives --install /usr/bin/python python /opt/pyenv/shims/python 100 \
    && update-alternatives --install /usr/bin/python3 python3 /opt/pyenv/shims/python3 100 \
    && update-alternatives --install /usr/bin/pip pip /opt/pyenv/shims/pip 100 \
    && update-alternatives --install /usr/bin/pip3 pip3 /opt/pyenv/shims/pip3 100

ENV PYTHONPATH=${PYTHONPATH}:/opt/pyenv/versions/3.7.1/lib/python3.7/site-packages

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -

RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

RUN curl -sL https://deb.nodesource.com/setup_8.x -o ~/nodesource_setup.sh \
    && sudo bash ~/nodesource_setup.sh \
    && sudo apt-get update \
    && sudo apt-get install -y --no-install-recommends openssh-client yarn nodejs tzdata \
    && rm ~/nodesource_setup.sh

RUN yarn global add parcel-bundler@1.12.3

USER conan
WORKDIR /home/conan

RUN mkdir -p /home/conan/.conan \
    && printf 'eval "$(pyenv init -)"\n' >> ~/.bashrc \
    && printf 'eval "$(pyenv virtualenv-init -)"\n' >> ~/.bashrc
