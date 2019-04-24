# xymon-checks
Additional Xymon Monitor addon scripts for checking various things

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

