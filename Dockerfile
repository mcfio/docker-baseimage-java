FROM mcfio/xenial
MAINTAINER nmcfaul

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"

# Java Version
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 144
ENV JAVA_VERSION_BUILD 01
ENV JAVA_PACKAGE       server-jre
ENV JAVA_SHA256_SUM    8ba6f1c692518beb0c727c6e1fb8c30a5dfcc38f8ef9f4f7c7c114c01c747ebc
ENV JAVA_URL_ELEMENT   090f390dda5b47b9b721c7dfaa008135

# Set environment
ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin

RUN apt-get update \
  && apt-get install -y \
    unzip \
  && mkdir -p /opt \
  && curl -jkLH "Cookie: oraclelicense=accept-securebackup-cookie" -o java.tar.gz http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_URL_ELEMENT}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
  && echo "$JAVA_SHA256_SUM  java.tar.gz" | sha256sum -c - \
  && gunzip -c java.tar.gz | tar -xf - -C /opt \
  && ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk \
  && curl -jkLH "Cookie: oraclelicense=accept-securebackup-cookie" -o jce_policy-8.zip http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip \
  && unzip jce_policy-8.zip -d /tmp \
  && cp /tmp/UnlimitedJCEPolicyJDK8/*.jar /opt/jdk/jre/lib/security/ \

  # clean up
  && rm -f java.tar.gz \
  && rm -rf /opt/jdk/*src.zip \
           /opt/jdk/lib/missioncontrol \
           /opt/jdk/lib/visualvm \
           /opt/jdk/lib/*javafx* \
           /opt/jdk/jre/lib/plugin.jar \
           /opt/jdk/jre/lib/ext/jfxrt.jar \
           /opt/jdk/jre/bin/javaws \
           /opt/jdk/jre/lib/javaws.jar \
           /opt/jdk/jre/lib/desktop \
           /opt/jdk/jre/plugin \
           /opt/jdk/jre/lib/deploy* \
           /opt/jdk/jre/lib/*javafx* \
           /opt/jdk/jre/lib/*jfx* \
           /opt/jdk/jre/lib/amd64/libdecora_sse.so \
           /opt/jdk/jre/lib/amd64/libprism_*.so \
           /opt/jdk/jre/lib/amd64/libfxplugins.so \
           /opt/jdk/jre/lib/amd64/libglass.so \
           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jdk/jre/lib/amd64/libjavafx*.so \
           /opt/jdk/jre/lib/amd64/libjfx*.so \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/*  \
  && rm -rf /var/tmp/*