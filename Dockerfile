FROM ubuntu:noble

ENV DEBIAN_FRONTEND=noninteractive

# Install basic Apt Packages
RUN apt-get update \
  && apt-get install -y \
  busybox \
  curl \
  tar \
  xz-utils \
  gnupg \
  locales \
  yq \
  ca-certificates \
  lib32gcc-s1 lib32stdc++6 lib32z1 \
  && apt-get clean autoclean \
  && apt-get autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Configure locale
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen

# Install wine and its dependencies
RUN dpkg --add-architecture i386 \
  && apt-get update \
  && apt-get install -y --no-install-recommends wine wine64 winbind xvfb wine32:i386 \
  && apt upgrade -y \
  && mkdir /usr/share/wine/mono \
  && curl -sfLo - https://dl.winehq.org/wine/wine-mono/8.1.0/wine-mono-8.1.0-x86.tar.xz | tar -Jxpf - -C /usr/share/wine/mono \
  && apt-get clean autoclean \
  && apt-get autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Add winetricks
RUN curl -sfLo /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
  && chmod a+x /usr/bin/winetricks

# Add Xpra
RUN apt-get update \
  && apt-get install -y wget gnupg xvfb x11-xserver-utils python3-pip \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://xpra.org/gpg.asc -o /etc/apt/keyrings/xpra.asc \
  && chmod 644 /etc/apt/keyrings/xpra.asc \
  && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/xpra.asc] https://xpra.org/ noble main" > /etc/apt/sources.list.d/xpra.list \
  && apt-get update \
  && apt-get install -y xpra \
  && mkdir -p /run/user/0/xpra \
  && apt-get clean autoclean \
  && apt-get autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Install s6-overlay
ENV S6_OVERLAY_VERSION="3.2.1.0"
RUN curl -sfLo - https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz | tar -Jxpf - -C /
RUN curl -sfLo - https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz | tar -Jxpf - -C /

# Create required directories
RUN mkdir -p /usr/lib/steamcmd /game

# Install and update steamcmd
RUN curl -sfLo - http://media.steampowered.com/client/steamcmd_linux.tar.gz | tar -xzf - -C /usr/lib/steamcmd \
  && /usr/lib/steamcmd/steamcmd.sh \
  +login anonymous \
  +quit

# install confd
RUN curl -sfLo /usr/bin/gomplate https://github.com/hairyhenderson/gomplate/releases/download/v4.3.3/gomplate_linux-amd64 \
  && chmod +x /usr/bin/gomplate

# Copy s6-overlay configs
COPY s6-rc.d /etc/s6-overlay/s6-rc.d
COPY gameservers /gameservers

# Copy bip-ops
COPY bip-ops.sh /usr/bin/bip-ops

# S6 settings
ENV S6_VERBOSITY=1 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# Wine settings
ENV WINEARCH=win64 \
    DISPLAY=:99

ENV VALIDATE_SERVER_FILES=true

# Expose Xpra web server for games that require an X display
EXPOSE 7756

ENTRYPOINT ["/init"]

CMD ["/usr/bin/bip-ops"]
