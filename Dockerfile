FROM lasote/conangcc7
MAINTAINER VCA Technology <developers@vcatechnology.com>

# Build-time metadata as defined at http://label-schema.org
ARG PROJECT_NAME
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="$PROJECT_NAME" \
      org.label-schema.description="A docker images for conan gcc7 with additional tools used by VCA" \
      org.label-schema.url="https://www.conan.io" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/vcatechnology/docker-conangcc7" \
      org.label-schema.vendor="VCA Technology" \
      org.label-schema.version=$VERSION \
      org.label-schema.license=MIT \
      org.label-schema.schema-version="1.0"

RUN sudo apt-get update
RUN sudo apt-get install -y python3 python3-pip curl openssh-client cmake tzdata
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_8.x -o ~/nodesource_setup.sh
RUN sudo bash ~/nodesource_setup.sh
RUN sudo apt-get update
RUN sudo apt-get install -y openssh-client cmake yarn nodejs tzdata
RUN sudo pip3 install --upgrade pip
RUN sudo pip install conan==1.11.2 pystache scp paramiko
