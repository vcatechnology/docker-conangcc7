FROM lasote/conangcc7
MAINTAINER VCA Technology <developers@vcatechnology.com>

# Build-time metadata as defined at http://label-schema.org
ARG PROJECT_NAME
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="$PROJECT_NAME" \
      org.label-schema.description="A docker images for conan gcc5 with additional tools used by VCA" \
      org.label-schema.url="https://www.conan.io" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/vcatechnology/docker-conangcc7" \
      org.label-schema.vendor="VCA Technology" \
      org.label-schema.version=$VERSION \
      org.label-schema.license=MIT \
      org.label-schema.schema-version="1.0"

RUN sudo apt-get update
RUN sudo apt-get install -y python3 python3-pip
RUN sudo pip3 install --upgrade pip
RUN sudo pip3 install conan==1.4.1 meson==0.46.1 scp paramiko
