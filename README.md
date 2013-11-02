bin-scripts
===========

Trivial, one-shot, random, often pointless scripts that I either like to have
hanging around on a variety of machines, or I just don't want to lose.

Intended to be symlinked by the dot-files repo' setup.sh script so that all of
these are in the user's path.

Scripts
=======

dfh
---

A sorted (by mount point name) list of filesystems on the current machine,
with sizes in human-readable format.

duh
---

Sorted summary of disk usage by directory, in human-readable formats (MiB, KiB,
GiB, etc. -- instead of raw bytes). Accepts optional arguments of depth or
target directory.
