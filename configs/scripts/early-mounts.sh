#!/bin/sh
set -e
mountpoint -q /proc || mount -t proc proc /proc
mountpoint -q /sys  || mount -t sysfs sysfs /sys
mountpoint -q /run  || mount -t tmpfs -o mode=0755,nosuid,nodev tmpfs /run
mountpoint -q /dev/pts || mount -t devpts devpts /dev/pts -o gid=5,mode=620
mountpoint -q /dev/shm || mount -t tmpfs tmpfs /dev/shm -o nosuid,nodev
