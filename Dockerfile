FROM ubuntu:20.04

ARG username
ARG gid
ARG uid
ARG password

# default screen size
ENV XRES=1280x800x24

# Ubuntu doesn't set this var and without it avery qemu fails
ENV USER=${username}

# supress dialogue when installing tzdata
ENV TZ=Europe/Warsaw
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOF
# To pass ${username} to Dockerfile go 'docker build --build-arg username=<user>'
groupadd --gid ${gid} ${username}
useradd --uid ${uid} --gid ${gid} --shell /bin/bash --create-home ${username}
usermod -a -G sudo ${username}
usermod -a -G kvm ${username}
echo "${username}:${password}" | chpasswd
EOF

# This apt-conf includes the http proxy used in Intel. Run it only for Intel.
#COPY apt.conf /etc/apt/

RUN set -e \
  && apt-get update -y \
  \
  # essentially Yocto tools
  && apt-get install -y \
     build-essential chrpath cpio debianutils diffstat file gawk \
     gcc iputils-ping libacl1 liblz4-tool \
     python3 python3-git python3-jinja2 python3-pexpect \
     python3-pip python3-subunit \
     locales socat texinfo unzip wget xz-utils zstd \
  \
  # general tools
     sudo vim tmux gzip git cpu-checker \
     perl libterm-readkey-perl \
     libpixman-1-0 libpixman-1-dev libglib2.0-0 \
  \
  # required from sv
     dc time libelf1 \
  \
  # GUI, VNC, noVNC
     apt-utils supervisor openssh-server \
     xserver-xorg xvfb x11vnc dbus-x11 xfce4 \
     xfce4-terminal xfce4-xkb-plugin \
     novnc websockify \
  \
  # locale generation
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen \
  \
  # global locale environment
  && printf "LANG=en_US.UTF-8\nLC_ALL=en_US.UTF-8\nLANGUAGE=en_US:en\n" > /etc/environment \
  \
  # cleanup
  && rm -rf /var/lib/apt/lists/*

# sshd fix
RUN mkdir -p /run/sshd && chmod 0755 /run/sshd && \
   rm -f /etc/ssh/ssh_host_* && \
   ssh-keygen -A && \
   chmod 600 /etc/ssh/ssh_host_*_key && \
   chmod 644 /etc/ssh/ssh_host_*_key.pub && \
   /usr/sbin/sshd -t

# Put MOTD in .bash_aliases
COPY .bash_aliases /home/${username}

# install gh. in Ubuntu 20.04 it is not in apt
COPY gh_2.69.0_linux_amd64.deb /home/${username}
RUN dpkg -i /home/${username}/gh_2.69.0_linux_amd64.deb

# make /bin/sh symlink to bash instead of running dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Install firefox
RUN apt-get -y update && apt-get -y install firefox

# add my sys config files
COPY etc /etc

# user config files
# terminal
COPY config/xfce4/terminal/terminalrc /home/${username}/.config/xfce4/terminal/terminalrc
# wallpaper
COPY config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml /home/${username}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
# icon theme
COPY config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml /home/${username}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

RUN chown -v -R ${username}:${username} /home/${username}

# ports
EXPOSE 22 5900 6080

# # default command
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
