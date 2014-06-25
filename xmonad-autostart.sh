#!/bin/sh

HOST=$(hostname)
STARTUPD="${HOME}/.xmonad/startup.d"
HOSTDOTD="${STARTUPD}/${HOST}.d"

# startup scripts to be run on every host
if [[ -d "${STARTUPD}" ]]; then
    for fn in `ls ${STARTUPD}`; do
        if [[ -L "${STARTUPD}/${fn}" ]]; then
            ${STARTUPD}/${fn}
        fi
    done
fi

# host-specific scripts, which should be symlinks into startup.d/available/
if [[ -d "${HOSTDOTD}" ]]; then
    for fn in `ls ${HOSTDOTD}`; do
        if [[ -L "${HOSTDOTD}/${fn}" ]]; then
            ${HOSTDOTD}/${fn}
        fi
    done
fi

