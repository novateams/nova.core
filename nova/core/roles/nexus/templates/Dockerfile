FROM sonatype/nexus3:{{ nexus_version }}

USER root

# IPv6 support
# https://support.sonatype.com/hc/en-us/articles/23895584612243-How-do-you-enable-support-for-ipv6-in-Nexus-Repo-3
RUN sed -ri 's/(-Djava.net.preferIPv4Stack=).*/\1false/g' /opt/sonatype/nexus/bin/nexus.vmoptions

USER nexus
