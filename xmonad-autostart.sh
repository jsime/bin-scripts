#!/bin/sh

HOST=$(hostname)

xrdb -merge ~/.Xresources

# startup scripts to be run on every host
for s in `ls ~/.xmonad/startup.d/*`; do
    if [ -x "$s" ]; then
        ${s}
    fi
done

# host-specific scripts, which should be symlinks into startup.d/available/
if [ -d "~/.xmonad/startup.d/${HOST}.d" ]; then
    for s in `ls ~/.xmonad/startup.d/${HOST}.d/*`; do
        if [ -x "$s" ]; then
            ${s}
        fi
    done
fi

