```
       ______
      (  mu  )
       ------
          \   ^__^
           \  (oo)\_______                        l i g h t
              (__)\       )\/\
                  ||----w |
                  ||     ||
```

<br/>

## 1: howtostart

[alpine](https://alpinelinux.org/downloads/) standard | extended | virtual image & [installation](https://docs.alpinelinux.org/user-handbook/0.1a/Installing/manual.html)

```bash
# example
setup-keymap → setup-hostname → setup-interfaces  ↓
  rc-service networking start → setup-timezone    ↓
setup-apkrepos → passwd → setup-sshd → setup-ntp  ↓
setup-disk                              → reboot


# note: do not create a user account (since 3.16.0)
#     per setup-user or in a setup-alpine step
# else: install.sh will exit 1 in silence - for now
```

## 2: git, clone

```
# apk add git
# git clone --depth 1 https://github.com/dronezne/light.git
```

## 3: run script

```
# sh light/install.sh
```

## overview

```
↓ download screenshot: https://github.com/dronezne/light/blob/main/screen.png
```

## trivials

```
.. but non-self-explanatory
 - execute commands as another user → run: doas
 ~ resolution, refresh rate sway config line 10
 ~ cursor theme and/or size sway config line 34
 ~ default terminal font - size foot.ini line 7
 - local-video-profile: $ mpvl <_path_to_file_>
 - local-audio-detached: $ ffp <_path_to_file_>
 - if laptop: $ doas powertop --html=power.html
 - interrupt key = ctrl+shift+c (ctrl+c = copy)
```

## function

```bash
$ cbb       # <cmd> busybox ?
$ nnn       # tiny adjustment
$ dnv       # doasnvim ~/init
$ 2fa       # <foo>  oathtool
$ cpu       # (oo) → $ cpu -h
$ esa       # eval → ssh agent
$ img       # picture overview
$ chc       # chrony check ntp
$ iso       # wipe -a/-o write
$ cfn       # cleanup filename
$ mix       # jumbled overview
$ off       # net → go offline
$ trim      # fstrim / +output
$ logs      # (oo) → $ logs -h
$ mpvl      # mpv localprofile
$ pkgi      # info: $ pkgi -h
$ fhd       # <foo> dd fish ↓
$ rca       # status services
$ ffp       # ffplay detached
$ rad       # (oo) → $ rad -h
$ man       # more less 4 man
$ ipt       # (oo) → $ ipt -h
$ mpc       # kernel ↓modules
$ sh2       # sync /home/ to:
$ rcl       # rclog: $ rcl -h
$ ff        # ? → $ ff --help
$ pw        # pass: → $ pw -h
$ cd        # cd + list files
$ nt        # note: → $ nt -h
$ on        # net → go online
$ se        # hwmon  coretemp
$ qv        # <kuh> ? var set
$ yt        # ⏎ <url> ↓stream
$ rs        # reset  terminal
$ fp        # fish record off
$ vi        # stands 4 neovim
$ gd        # git diff less+c
```

## shorten

```bash
$ fhd      # no shell history
$ 2fa      # no shell history
$ pw       # no shell history
$ nt       # no shell history
$ rm       # careful +verbose
# git commands: $ abbr --show
```
