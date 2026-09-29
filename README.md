# kubyl-debug

The debug image behind the **node shell** of [Kubyl](https://kubyl.dev), the native Kubernetes
desktop client. It is a small Alpine image packed with the tools you want when something is
wrong on a node.

```
docker pull docker.io/tyrola/kubyl-debug:3.24
```

## How Kubyl uses it

Kubyl starts a privileged pod on the chosen node with `hostPID`, `hostNetwork` and `hostIPC`,
mounts the node's root filesystem at `/host`, keeps the pod alive with `sh -c "sleep …"` and
execs `bash -l` into it. You land in this image with the node's processes, network and
filesystem in view; run

```
chroot /host
```

for a shell on the node itself. A short banner with those hints is shown whenever an
interactive shell starts (set `NO_COLOR=1` to drop the colors).

The image does not depend on its entrypoint: any `command` works, as long as it keeps the pod
running (`sleep`, `sh`, `bash` and `nsenter` are all present). Without a command it runs
`bash -l`.

### Without Kubyl

```sh
kubectl debug node/<node> -it --image=docker.io/tyrola/kubyl-debug:3.24 --profile=sysadmin
# then: chroot /host
```

## What's inside

All packages come from Alpine `main`/`community`, installed in a single layer.

| Area | Packages |
| --- | --- |
| Shell and basics | `bash` (default shell), `bash-completion`, `coreutils` (`chroot`, …), `findutils`, `grep`, `sed`, `gawk`, `less`, `file`, `jq`, `vim`, `tmux`, `curl`, `wget`, `rsync`, `tar`, `pv`, `ca-certificates`, `tzdata` |
| Processes and system | `procps-ng` (`ps`, `pkill`, `top`, `free`, …), `psutils`, `htop`, `ctop`, `strace`, `lsof`, `sysstat` (`iostat`, `mpstat`, …), `kmod`, `pciutils`, `usbutils` |
| Networking | `tcpdump`, `iftop`, `nload`, `net-tools` (`netstat`, `ifconfig`), `iproute2` (`ip`, `ss`), `ethtool`, `iputils` (`ping`), `bind-tools` (`dig`, `nslookup`), `mtr`, `traceroute`, `netcat-openbsd` (`nc`), `socat`, `iperf3`, `conntrack-tools`, `iptables`, `nftables` |
| Disks, mounts, filesystems | `util-linux` + `util-linux-misc` (`mount`, `blkid`, `lsblk`, `findmnt`, `nsenter`, …), `ncdu`, `smartmontools`, `hdparm`, `nvme-cli`, `parted`, `gptfdisk`, `mdadm`, `e2fsprogs(-extra)`, `xfsprogs(-extra)`, `btrfs-progs`, `dosfstools`, `exfatprogs`, `ntfs-3g(-progs)`, `nfs-utils`, `cifs-utils`, `lvm2`, `cryptsetup`, `squashfs-tools`, `fuse`, `fuse3`, `sshfs` |

Note on `ctop`: it talks to Docker/runc only. On most Kubernetes nodes (containerd, CRI-O) it
cannot see the containers; use `chroot /host` and the node's `crictl` instead.

## Tags

Images are multi-arch (`linux/amd64`, `linux/arm64`) on Docker Hub as `tyrola/kubyl-debug`.

| Tag | Built from | Moves |
| --- | --- | --- |
| `3.24` | `main`, on Alpine 3.24 | on every push to `main` and weekly |
| `latest` | `main` | on every push to `main` and weekly |
| `X.Y.Z`, `X.Y`, `X` | git tags `vX.Y.Z` | when a release is tagged |

The `3.24` tag follows the Alpine minor line, so pin it if you want to stay on that line. A
weekly scheduled build (without cache) picks up Alpine security updates. When the base moves
to a new Alpine line, the `ALPINE_LINE` in the workflow changes with it and a new tag appears.

## CI

`.github/workflows/build.yml` builds on pull requests (no push) and on pushes to `main`,
`v*.*.*` tags and a weekly schedule. It smoke-tests the amd64 image, then builds both
architectures and pushes them. The repository needs two Actions secrets:

- `DOCKERHUB_USERNAME`: the Docker Hub user allowed to push `tyrola/kubyl-debug`
- `DOCKERHUB_TOKEN`: a Docker Hub access token for that user (read/write)

## Build locally

```sh
docker build -t kubyl-debug .
docker run --rm -it kubyl-debug
docker buildx build --platform linux/amd64,linux/arm64 -t kubyl-debug .
```

## License

MIT, see [LICENSE](LICENSE).
