# Kubyl node debug image: the toolbox behind Kubyl's "node shell".
#
# Kubyl starts it as a privileged pod (hostPID, hostNetwork, hostIPC) with the node's root
# filesystem mounted at /host and overrides the command (`sh -c "sleep ..."`), then execs
# `bash -l` into it. `chroot /host` gives a shell on the node itself.
FROM alpine:3.24

LABEL org.opencontainers.image.title="kubyl-debug" \
      org.opencontainers.image.description="Node debug shell image for the Kubyl Kubernetes desktop client" \
      org.opencontainers.image.source="https://github.com/BirknerAlex/kubyl-debug-image" \
      org.opencontainers.image.licenses="MIT"

# One layer, no apk cache. Grouped by purpose; everything is in Alpine main/community.
RUN apk add --no-cache \
        # shell and basics
        bash bash-completion coreutils findutils grep sed gawk less file jq vim tmux \
        ca-certificates tzdata curl wget rsync tar pv \
        # processes and system
        procps-ng psutils htop ctop strace lsof sysstat kmod pciutils usbutils \
        # networking
        tcpdump iftop nload net-tools iproute2 ethtool iputils bind-tools mtr traceroute \
        netcat-openbsd socat iperf3 conntrack-tools iptables nftables \
        # disks, mounts and filesystems
        util-linux util-linux-misc ncdu smartmontools hdparm nvme-cli parted gptfdisk mdadm \
        e2fsprogs e2fsprogs-extra xfsprogs xfsprogs-extra btrfs-progs dosfstools exfatprogs \
        ntfs-3g ntfs-3g-progs nfs-utils cifs-utils lvm2 cryptsetup squashfs-tools \
        fuse fuse3 sshfs

COPY rootfs/ /

# bash is the default shell; ENV makes an interactive busybox `sh` show the MOTD too.
ENV SHELL=/bin/bash \
    ENV=/etc/profile.d/kubyl-motd.sh

WORKDIR /root
CMD ["bash", "-l"]
