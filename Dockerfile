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
  && apt update \
  && apt install -y --no-install-recommends wine wine64 winbind xvfb wine32:i386 \
  && apt upgrade -y \
  && mkdir /usr/share/wine/mono \
  && curl -sfLo - https://dl.winehq.org/wine/wine-mono/8.1.0/wine-mono-8.1.0-x86.tar.xz | tar -Jxpf - -C /usr/share/wine/mono

# Add winetricks
RUN curl -sfLo /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
  && chmod a+x /usr/bin/winetricks

# Add Xpra
RUN apt-get update \
  && apt-get install -y wget gnupg xvfb x11-xserver-utils python3-pip \
  && echo "deb [arch=amd64] https://xpra.org/ noble main" > /etc/apt/sources.list.d/xpra.list \
  && curl -sfLo - https://xpra.org/gpg.asc | apt-key add - \
  && apt-get update \
  && apt-get install -y xpra \
  && mkdir -p /run/user/0/xpra

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

# Copy s6-overlay configs
COPY s6-rc.d /etc/s6-overlay/s6-rc.d

# Copy healthcheck
COPY healthcheck.sh /usr/bin/healthcheck

# Set default environment variables
ENV S6_VERBOSITY=1
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

ENV DATA_DIR="/serverdata"
ENV STEAMCMD_DIR="${DATA_DIR}/steamcmd"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV GAME_ID="template"
ENV GAME_NAME="template"
ENV GAME_PARAMS="template"
ENV GAME_PORT=27015
ENV VALIDATE="false"

# Wine settings
ENV USE_WINE="true" \
    # WINEDATA_PATH="/winedata" \
    WINEARCH=win64 \
    # WINEPREFIX="/wine" \
    DISPLAY=:99

# Expose Xpra web server for games that require an X display
EXPOSE 7756

# Expose UDP game port
EXPOSE 7777

# Expose Query Port
EXPOSE 7777

ENTRYPOINT ["/init"]

CMD ["/usr/bin/healthcheck"]
