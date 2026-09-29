# Kubyl node debug shell banner. Sourced by login shells (/etc/profile), interactive bash
# (/etc/bash/kubyl-motd.sh links here) and interactive busybox sh (via $ENV).
# `kubectl exec` never runs login(1), so /etc/motd would not be shown on its own.

case $- in
    *i*) ;;
    *) return 0 2>/dev/null || exit 0 ;;
esac
[ -n "$KUBYL_MOTD_SHOWN" ] && return 0
export KUBYL_MOTD_SHOWN=1

if [ -t 1 ] && [ -z "$NO_COLOR" ]; then
    b=$(printf '\033[1;38;2;116;173;232m') # Kubyl blue (#74ade8), bold
    h=$(printf '\033[1m')
    d=$(printf '\033[2m')
    r=$(printf '\033[0m')
else
    b='' h='' d='' r=''
fi

cat <<MOTD
${b}     .-'-.${r}
${b}  .-'     '-.${r}    ${h}Kubyl node debug shell${r}
${b}  |'-.   .-'|${r}    The node's root filesystem is mounted at ${h}/host${r}.
${b}  |   '+'   |${r}    Run ${h}chroot /host${r} for a shell on the node itself.
${b}  |    |    |${r}
${b}  '-.  |  .-'${r}    ${d}tcpdump htop strace lsof mtr iftop nload ncdu vim curl jq ...${r}
${b}     '-+-'${r}       ${d}https://kubyl.dev${r}

MOTD
unset b h d r
