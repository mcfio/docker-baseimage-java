FROM mcfio/alpine
MAINTAINER nmcfaul

# Java Version
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 144
ENV JAVA_VERSION_BUILD 01
ENV JAVA_PACKAGE       server-jre
ENV JAVA_SHA256_SUM    8ba6f1c692518beb0c727c6e1fb8c30a5dfcc38f8ef9f4f7c7c114c01c747ebc
ENV JAVA_URL_ELEMENT   090f390dda5b47b9b721c7dfaa008135
ENV GLIBC_VERSION      2.23-r4

# Set environment
ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin

RUN apk upgrade --update \
  && apk add --no-cache --virtual=build-dependencies \
    curl \
    tar \
  && apk add --no-cache \
    libstdc++ \
  
  # Install glibc
  && for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do curl -sSL https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done \
  && apk add --allow-untrusted /tmp/*.apk \
  && ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) \
  && echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh \
  && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib \

  # Install Oracle Java
  && mkdir -p /opt \
  && curl -jkLH "Cookie: oraclelicense=accept-securebackup-cookie" -o /tmp/java.tar.gz http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_URL_ELEMENT}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
  && echo "$JAVA_SHA256_SUM /tmp/java.tar.gz" | sha256sum -c - \
  && gunzip -c /tmp/java.tar.gz | tar -xf - -C /opt \
  && ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk \
  
  # Install JCE Policy
  && curl -jkLH "Cookie: oraclelicense=accept-securebackup-cookie" -o /tmp/jce_policy-8.zip http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip \
  && unzip /tmp/jce_policy-8.zip -d /tmp \
  && cp /tmp/UnlimitedJCEPolicyJDK8/*.jar /opt/jdk/jre/lib/security/ \

  # clean up
  && apk del --purge \
    build-dependencies \
    glibc-i18n \
  && rm -rf /opt/jdk/*src.zip \
    /opt/jdk/jre/plugin \
    /opt/jdk/jre/bin/javaws \
    /opt/jdk/jre/bin/jjs \
    /opt/jdk/jre/bin/orbd \
    /opt/jdk/jre/bin/pack200 \
    /opt/jdk/jre/bin/policytool \
    /opt/jdk/jre/bin/rmid \
    /opt/jdk/jre/bin/rmiregistry \
    /opt/jdk/jre/bin/servertool \
    /opt/jdk/jre/bin/tnameserv \
    /opt/jdk/jre/bin/unpack200 \
    /opt/jdk/jre/lib/javaws.jar \
    /opt/jdk/jre/lib/deploy* \
    /opt/jdk/jre/lib/desktop \
    /opt/jdk/jre/lib/*javafx* \
    /opt/jdk/jre/lib/*jfx* \
    /opt/jdk/jre/lib/amd64/libdecora_sse.so \
    /opt/jdk/jre/lib/amd64/libprism_*.so \
    /opt/jdk/jre/lib/amd64/libfxplugins.so \
    /opt/jdk/jre/lib/amd64/libglass.so \
    /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
    /opt/jdk/jre/lib/amd64/libjavafx*.so \
    /opt/jdk/jre/lib/amd64/libjfx*.so \
    /opt/jdk/jre/lib/ext/jfxrt.jar \
    /opt/jdk/jre/lib/ext/nashorn.jar \
    /opt/jdk/jre/lib/oblique-fonts \
    /opt/jdk/jre/lib/plugin.jar \
    /tmp/* /var/cache/apk/* \
