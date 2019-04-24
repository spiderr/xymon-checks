========================
 raid-monitor for Xymon
========================

-----------------------------------------------------
 *an extension for Xymon to monitor RAID subsystems*
-----------------------------------------------------

        |RAID-MONITOR| uses a very generic approach to make monitoring
        new/currently unsupported RAID-systems very easy. Given the availability
        of a commandline tool to query the RAID-status adding support for a new
        system should be a matter of minutes.


:Description: Documentation for raid-monitor for Xymon
:Author: Thomas Eckert <thomas.eckert@it-eckert.de>
:Contact: please contact Author
:Date: 2014-06-16
:Version: 0.9.8
:Copyright: |copyright|
:Info: see <http://www.it-eckert.com/software/raid-monitor> for more information

.. sectnum::

.. contents:: Table of Contents
   :backlinks: top


Overview
========

Monitoring of RAID systems is essential as an unmaintained RAID system only
takes longer to break completely. So you need to know the status of your RAID
subsystems.

Due to the huge number of available RAID cards (hardware RAID-controllers are
available from LSI, Adaptec, 3ware -- now also an LSI company, Areca) and
different softare RAID stacks on the operating systems (Linux has MDRAID,
FreeBSD has vinum, ...) writing a separate monitoring-script for each system is
time-consuming and does give much additional benefit (see argumentation below
why |RAID-MONITOR| only shows a green or red status).

Instead of writing a custom check for each RAID system |RAID-MONITOR|_ uses the
following generic approach:

1. From a know-good state of the raidset a reference-file is generated in a
   manual "learning" or "configuration" step.

2. Each test-run compares the current state with that reference-file and if
   differences are found the ``raid``-column goes red (because anything
   differing from the know-good state has to be taken seriously to avoid
   potential data-loss).

This has the drawback that variable output (such as environmentals) cannot be
monitored but buys a very easy monitoring of the RAID sets themself. If
environmentals (such as temperature of the HDDs) are needed these have to be
handled by a separate script.


Supported RAID systems
======================

Modules for the following RAID-cards/-systems are included along with a
sample-configuration that can easily be adjusted to the specific setup in other
environments.

3ware
        3ware/AMCC/LSI RAID-Cards via ``tw_cli``

Areca
        Areca based RAID-cards via the Areca CLI

Adaptec (aacraid)
        Adaptec-based SAS/SATA unified RAID-cards (like the 5405 ...) via
        ``arcconf`` CLI included in the package of Adaptec Storage Manager
        (ASM); this *should* also work for the IBM ServeRAID-Adapters as these
        are Adaptec OEM-parts.

Linux software-raid (mdraid)
        Linux software-RAID (monitored via ``/proc/mdstat``)

LSI Megaraid 
        LSI Megaraid, Dell PERC, via ``MegaCli``


Requirements
============

Beside the obvious requirement for a Xymon (or hobbit) system and a RAID system
the following is needed:

- the ``bash(1)`` shell with array-support (bash 3.x and 4.x tested)

- a ``diff(1)`` utility (GNU-diff tested)

- ``tail(1)`` and ``sed(1)`` needed to generate a nice status-summary

- the ``tee(1)`` utility (used in debug-mode only)

- the raid-controller tools to fetch the status (e.g. ``tw_cli`` for 3ware,
  ``cli32|cli64`` for Areaca, ``MegaCli`` for LSI cards, ...)

- most likely ``sudo`` for executing the raid-tool as non-root (the Xymon user)


Installation and Usage
=======================

- verify that the RAID status can be queried with the command configured in
  ``raid-monitor.cfg`` in ``TW_CLI``, e.g. for 3ware verify that the **Xymon
  user** can run ``tw_cli`` via ``sudo``::

        ## Sample /etc/sudoers-line for tw_cli:
        ##	xymon  ALL=(ALL)       NOPASSWD: /sbin/tw_cli

        ## Note: "areca-cli" does not need root-privileges as areca-cli requests
        ##       authentication of the user for "dangerous" operations.

  Note: for Areca cards ``ARECA_CLI`` is used: verify that the path and name of
  the CLI fits your installation.

- copy the monitoring-script ``raid-monitor`` and the configuration-file
  ``raid-monitor.cfg`` to the ``ext``-directory of your Xymon (or hobbit)
  installation where the RAID system to monitor is installed/running. The
  search-path for ``raid-monitor.cfg`` is

  1. ``$BBHOME/ext`` (next to ``raid-monitor`` script)

  2. ``$BBHOME/etc/``


- adjust the config-file. In particular change ``MY_RAID`` to reflect your used
  system(s). Currently supported are

  - 3ware HW-RAID cards (7xxx, 8xxx, 9xxx, tested w/ tw_cli up to v9.x)

  - Areaca HW-RAID cards (areca-cli v1.82)

  - Linux software raid (mdraid)

  Multiple raid-systems on the same host are supported, just add them
  space-separated, e.g. ``MY_RAID="3ware areca"``.
  If your RAID system is not supported read `Adding support for a new RAID
  system`_ below.

- enable the extension by adding ``raid-monitor-clientlaunch.cfg`` to your
  clientlaunch-directory or by appending it's contents to
  ``~hobbit/client/etc/clientlaunch.cfg``

- generate the reference-file for your configuration by running::

        ~/client/bin/bbcmd ~/client/ext/raid-monitor -r

- test the complete setup by running in debug-mode::

        ~/client/bin/bbcmd ~/client/ext/raid-monitor -d | grep "status .*\.raid"
        2010-08-01 21:42:10 Using default environment file /usr/lib/xymon/client/etc/hobbitclient.cfg
        $BB $BBDISP "status ${MACHINE}.raid green Sun Aug  1 21:42:10 CEST 2010 - 3ware 00sample RAID(s)

  => this example shows a "green" status for a configuration of 2 raid-modules
  (3ware and 00sample).
  If your status is non-green check your steps above.



Adding support for a new RAID system
====================================

For adding a new RAID system have a look at the existing modules in
``./raid.d/``, especially the sample-module ``00sample.raid`` (it shows the
usage of __loop() and __single_cmd() along with a helper-function for your new
raid-module).

A few notes about writing modules:

- the *module-filename* should be lowercase and **must** have the extension
  ``.raid``, e.g. ``00sample.raid``

- the *function-name* of the worker-function **must** be identical to the
  module-filename with a pre-pended ``_``, e.g. ``_00sample``. An arbritary
  number of helper-functions can be defined in the module, to avoid
  naming-conflicts with other modules it is good practice to choose something
  like ``_00sample_helper``

- see ``raid.d/areca.raid`` for a real-live example of a helper-function:
  ``_areca_cliversion()`` is used to extract the version-number of the CLI-tool
  with some pipe-head-tail-fiddling as there is no other way to show the
  version of the tool; the function is called in ``_areca()`` of the same
  module-file.

- listing the requirements of the module in a comment at the top of the
  module-file is good practice

- consider sending me your new module to include it in the base-package


TODO
------------------------------------

- add notes about ./raid.d/-structure

- add some documentation (beside the sample-modules) "base-functions": _log(),
  _error(), _warn(); __loop(); __single_cmd()!


----



.. |RAID-MONITOR| replace:: *raid-monitor for Xymon*
.. _RAID-MONITOR: http://www.it-eckert.com/software/raid-monitor
.. |version| replace:: 0.9.8

.. |copy| unicode:: 0xA9 .. copyright sign
.. |copyright| replace:: Copyright |copy| 2006, 2007, 2008, 2009, 2010, 2011, 2014 Thomas Eckert, http://www.it-eckert.com/

.. header:: Documentation for |RAID-MONITOR| |version|
.. footer:: |copyright|

