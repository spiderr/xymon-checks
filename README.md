# Xymon Checks
These are custom XYMON monitor scripts that check various things common in a linux data center.

## dumpcheck
Monitor directories of backup files, most typically database dumps for time and significant changes in size.
Usage: dumpcheck.pl "/dir/to/check/foo_*:/path/to/check/bar*"

## freshfiles
Monitor directories to make sure all files have been updated within a certain time window.
Usage: freshfiles.pl [HOURS] "/path/to/dir1/*:/only/tarballs/in/dir2/*gz"
- 768 HOURS is 32 days which is ideal for monthly
- 26 HOURS is ideal for daily backpus

## rhn
Monitor configuration managment differences with RedHat Satellite 5.x and Spacewalk 2.*

You must have "rhncfg-client verify" installed and working.

## interface
This XYMON check uses ethtool to monitor network interfaces speeds. This is a fork of the iface check (link below) with the addition of a global --speed option to handle scenarios where hardware is faster than the switch, i.e. 10GbaseT nic, but only 1GbaseT on the switch.
https://blog.dafert.org/xymon-bigbrother-script-to-monitor-network-interfaces-duplex-settings-and-bonding/
