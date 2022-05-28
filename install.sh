#!/bin/sh
# shellcheck disable=SC3043

    vech() {
        local IFS=" "
        printf %s "$*"
    }

    riv() {
        setup-apkrepos
        exec "$0"
    }

    subs() {
        case $2 in
            *"$1"*)
                return 0 ;;
            *)
                return 1 ;;
        esac
    }

    clear

    echo "- preparation .."

    printf \\n

    # notice
    if subs ebspwm "$PWD"; then
        printf "\033[37;7merror\033[0m script executed from: %s\n" "$PWD"
        exit 1
    fi

    # notice
    apk add pciutils >/dev/null

    if lspci -k | grep -i -C 2 -E 'vga|3d' | grep -i -q -w 'nvidia'; then
        printf "\033[37;7msorry\033[0m this setup does not support nvidia"
        exit 1
    fi

    # apkr
    repos=/etc/apk/repositories

    sed -Ei '/test/!s/^((#[ ]?(http(|s)|ftp))|ftp|http\>)/https/' "$repos"

    if ! wget --quiet -T5 --spider "$(grep -m 1 '^https' "$repos")"; then
        true > "$repos"; riv
    fi

    sed -i '/edg/!s/^https/#&/' "$repos"; apk add -Uq --upgrade apk-tools

    # user
    printf "choose username: "
    read -r usn

    if test -z "$usn"; then
        exit 1
    fi

    adduser -h /home/"$usn" \
    -s /usr/bin/fish "$usn"

    if test "$?" -ne 0; then
        exit 1
    fi

    adduser "$usn" wheel
    adduser "$usn" video
    adduser root audio
    adduser "$usn" input
    adduser "$usn" audio

    dir=/home/"$usn"

    mv light "$dir"

    cd "$dir" || exit 1

    # fsbin
    sed -i -E 's/^tty(3|4|5|6)/#&/' /etc/inittab; apk upgrade --available

    # start
    apk add oath-toolkit-oathtool
    apk add mesa-vdpau-gallium
    apk add eudev; setup-udev
    apk add mesa-dri-gallium
    apk add mesa-va-gallium
    apk add apk-tools-doc
    apk add seatd-launch
    apk add iproute2-ss
    apk add ttf-dejavu
    apk add alsa-utils
    apk add iptables
    apk add newsboat
    apk add dbus-x11
    apk add chromium
    apk add i3status
    apk add xwayland
    apk add wayland
    apk add ncurses
    apk add nethogs
    apk add man-db
    apk add neovim
    apk add ffmpeg
    apk add wipefs
    apk add yt-dlp
    apk add lsblk
    apk add rsync
    apk add light
    apk add fish
    apk add less
    apk add grim
    apk add curl
    apk add sway
    apk add foot
    apk add doas
    apk add mpv
    apk add imv
    apk add fzf
    apk add nnn

    # itacc
    if lspci -k | grep -i -C2 -E 'vga|3d' | grep -i -q -w 'intel'; then
        apk add libva-intel-driver intel-media-driver
    fi

    # μcode
    if grep -i 'vendor' /proc/cpuinfo | uniq | grep -i -q 'intel'; then
        apk add intel-ucode
    fi

    # loho
    hna="$(grep '' /etc/hostname)"

    if ! grep -i -w -q 'search' \
    /etc/resolv.conf; then
        cut -c9- <<EOF \
        | tee /etc/hosts >/dev/null
        127.0.0.1 localhost.localdomain localhost $hna.localdomain $hna
        ::1       localhost.localdomain localhost $hna.localdomain $hna
EOF
    fi

    # ftzv
    TZ="$(find /etc/zoneinfo/ | tail -n1 | cut -d '/' -f4-)"

    # serv
    rc-service -q hostname restart
    rc-update -q add alsa default
    rc-update -q add dbus default
    rc-update -q add urandom boot
    rc-update -q add local default
    rc-update -q add acpid default

    # cssh
    rc-service -Nq sshd start

    cf=/etc/ssh/sshd_config
    re="$(grep -wE '^(PermitRootLogin no|UseDNS no|PasswordAuthe.*no)$' "$cf")"

    subs Pe "$re" || echo "PermitRootLogin no" | tee -a "$cf" >/dev/null
    subs eD "$re" || echo "UseDNS no" | tee -a "$cf" >/dev/null
    subs Au "$re" || echo "PasswordAuthentication no" | tee -a "$cf" >/dev/null

    # kern
     cut -c5- <<EOF \
    | tee -a /etc/sysctl.conf >/dev/null
    kernel.yama.ptrace_scope=3
    kernel.panic_on_oops=30
    vm.swappiness=30
    kernel.panic=30
    kernel.sysrq=0
    vm.panic_on_oom=1
    fs.protected_fifos=1
    fs.protected_regular=1
    vm.vfs_cache_pressure=90
EOF

    cut -c5- <<EOF \
    | tee -a /etc/sysctl.conf >/dev/null
    net.ipv4.icmp_ignore_bogus_error_responses=1
    net.ipv4.conf.default.accept_redirects=0
    net.ipv4.conf.all.accept_source_route=0
    net.ipv4.conf.all.accept_redirects=0
    net.ipv4.tcp_syncookies=1
    net.ipv4.tcp_rfc1337=1
    net.ipv4.ip_forward=0
    net.ipv4.conf.all.rp_filter=1
    net.ipv4.conf.default.rp_filter=1
    net.ipv4.conf.all.secure_redirects=0
    net.ipv4.conf.default.secure_redirects=0
    net.ipv4.conf.default.send_redirects=0
    net.ipv4.conf.all.send_redirects=0
    net.ipv4.tcp_timestamps=1
    net.ipv6.conf.lo.disable_ipv6=1
    net.ipv6.conf.all.disable_ipv6=1
    net.ipv6.conf.eth0.disable_ipv6=1
    net.ipv6.conf.default.disable_ipv6=1
    net.ipv4.icmp_echo_ignore_broadcasts=1
    net.ipv4.conf.default.accept_source_route=0
EOF

    # sbsh
    echo "export TZ='$TZ'" \
    | tee /etc/profile.d/timezone.sh >/dev/null

    # cron
    mkdir -p /etc/periodic/5min

    cut -c5- <<EOF | paste -s -d '\0' \
    >> /etc/crontabs/root
    */5     *       *       *       *
           run-parts /etc/periodic/5min
EOF

    # dpms
     cut -c5- <<'EOF' \
     > light/home/.config/sway/odpms.sh
    #!/bin/sh
    #
        read -r lcd < /tmp/lcd

        if test "$lcd" -eq 0; then
            swaymsg "output * dpms on"
            echo 1 > /tmp/lcd
        else
            swaymsg "output * dpms off"
            echo 0 > /tmp/lcd
        fi
EOF
    chmod +x light/home/.config/sway/odpms.sh

    # wavm
    wdg="$(cat /proc/sys/kernel/nmi_watchdog)"

    if test "$wdg" -eq 1; then
        echo "kernel.nmi_watchdog=0" \
        | tee -a /etc/sysctl.conf > /dev/null
    fi

    # jinc
    mkdir -p /etc/udhcpc

    cut -c 5- <<EOF > /etc/udhcpc/udhcpc.conf
    #RESOLV_CONF="no"
EOF

    # doas
    cut -c 5- <<EOF \
    | tee -a /etc/doas.d/doas.conf > /dev/null
    permit persist :wheel
    permit nopass keepenv root
    permit nopass :wheel cmd reboot
    permit nopass :wheel cmd poweroff
EOF

    # lbat
    cut -c5- <<'EOF' \
    | tee /etc/periodic/5min/lowbat >/dev/null
    #!/bin/sh
    #
    batt="$(ls -d /sys/class/power_supply/BAT*)"
    ac="$(cat /sys/class/power_supply/A*/online)"
    lev="$(cat "$batt"/capacity)"

    if test "$ac" -eq 1; then
        exit 0
    fi

    if test "$lev" -le 11 -a "$lev" -ge 8; then
        timeout 9 speaker-test \
        --frequency 500 -t sine >/dev/null 2>&1
    elif test "$lev" -le 7; then
        echo mem > /sys/power/state
    fi

    exit 0
EOF

    # lout
    key="$(grep '^KE' /etc/conf.d/loadkmap \
    | sed -e 's/.*map\/\(.*\)\.bmap.*/\1/')"

    swco=light/home/.config/sway/config

    if subs - "$key"; then
        lay="$(vech "$key" | cut -d '-' -f1)"
        vr="$(vech "$key" | cut -d '-' -f2-)"
        sed -i "s/xkb_layout/& $lay/" "$swco"
        sed -i "
        /xkb_la/a\ \txkb_variant $vr" "$swco"
    else
        sed -i "s/xkb_layout/& $key/" "$swco"
    fi

    # fish
    mkdir -p /etc/fish

    cat <<'EOF' \
    | tee -a /etc/fish/config.fish >/dev/null

    if status is-login
        if test -z $XDG_RUNTIME_DIR
            set -gx XDG_RUNTIME_DIR /tmp/(id -u)-runtime-dir
            if not test -d $XDG_RUNTIME_DIR
                mkdir $XDG_RUNTIME_DIR
                chmod 0700 $XDG_RUNTIME_DIR
            end
        end
    end
EOF

    sed -e '8s/[[:blank:]]\{8,\}/ /2' <<EOF \
    | tee -a /etc/fish/config.fish >/dev/null

    if status is-login
        set -gx TZ $TZ
        set -gx EDITOR nvim
        set -gx ENV \$HOME/.ashrc
        set -gx LESSHISTFILE "-"
        set -gx HOSTNAME (hostname)
        fish_add_path -P /bin /usr/bin \
        /sbin /usr/sbin /usr/local/bin
    end
EOF

    cat <<'EOF' \
    | tee -a /etc/fish/config.fish >/dev/null

    if status is-login
        umask 077
    end
EOF

    cat <<'EOF' \
    | tee -a /etc/fish/config.fish >/dev/null

    if status is-login
        if test -z "$DISPLAY" -a (tty) = /dev/tty1
            dbus-launch seatd-launch sway
        end
    end
EOF

    cut -c5- <<EOF \
    >>/etc/modprobe.d/blacklist.conf

    # additional
    install uvcvideo /bin/true
    install bluetooth /bin/true
EOF

    # idv
    chty="$(grep -E '8|9|10|14' \
    /sys/class/*/id/chassis_type)"

    # spl
    if test -n "$chty"; then
        mkdir -p /etc/acpi/LID
        cut -c9- <<EOF \
        > /etc/acpi/LID/00000080
        #!/bin/sh
        echo mem > /sys/power/state
EOF
    chmod +x /etc/acpi/LID/00000080
    fi

    # batt
    if test -n "$chty"; then
        apk add powertop >/dev/null
    fi

    # ash
    cat <<'EOF' \
    | tee "$dir"/.ashrc > /dev/null
    # funcs..
    rs() {
        tput reset
    }

    # alias..
    alias ll='ls -lhAX'
    alias sc='source ~/.ashrc'
EOF

    # rcco
    echo "rc_need=udev-settle" >> /etc/conf.d/localmount

    # grub
    lake="$(find /boot -name 'config-*' -maxdepth 1)"
    conf="$(grep -i -E '^conf.*shuffle.*p.*alloc.*y' "$lake")"
    para="$(grep -i -w 'y' /sys/module/page_alloc/parameters/shuffle)"

    if test -d /sys/firmware/efi; then
        if ! grep -w -q 'page_alloc.shuffle' /etc/default/grub; then
            if test -n "$conf" -a -z "$para"; then
                sed -i 's/LINUX_DEFAULT="/&page_alloc.shuffle=1 /' \
                /etc/default/grub; grub-mkconfig -o /boot/grub/grub.cfg
            fi
        fi
    fi

    # fcon
    uca=/usr/share/fontconfig/conf.avail; ecd=/etc/fonts/conf.d/

    ln -s "$uca"/10-scale-bitmap-fonts.conf "$ecd" >/dev/null 2>&1
    ln -s "$uca"/11-lcdfilter-default.conf "$ecd" >/dev/null 2>&1
    ln -s "$uca"/10-hinting-slight.conf "$ecd" >/dev/null 2>&1
    ln -s "$uca"/10-sub-pixel-rgb.conf "$ecd" >/dev/null 2>&1
    ln -s "$uca"/70-no-bitmaps.conf "$ecd" >/dev/null 2>&1
    ln -s "$uca"/45-latin.conf "$ecd" >/dev/null 2>&1

    fc-cache -f

    # bt
    batt="$(ls -d /sys/class/power_supply/BAT* | cut -d '/' -f 5)"
    adap="$(ls -d /sys/class/power_supply/A* | cut -d '/' -f 5)"

    # wgmo
    if ! lsmod | grep -i -w -q '^wireguard'; then
        echo wireguard | tee -a /etc/modules > /dev/null
    fi

    # lbco
    if test -n "$chty" -a -n "$batt" -a -n "$adap"; then
        chmod a+x /etc/periodic/5min/lowbat
        rc-update add crond default
    fi

    # perm
    chmod 600 /etc/doas.d/doas.conf
    chmod go-rwx /lib/modules /boot

    # rmfd
    find /etc/fish/* -type d -delete

    # cpco
    cp -r -T light/home "$dir"

    # user
    chown -R "${usn}":"${usn}" "${dir}"

    chmod go-rwx "$dir"
    chmod -R g-s "$dir"

    printf \\n

    printf "\033[37;7m# reboot \033[0m"
