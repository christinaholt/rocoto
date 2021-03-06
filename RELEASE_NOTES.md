# Release Notes

## New for Version 1.2.4

* Fix bugs relating to ~/.rocoto/log rotation
* Fix race condition bug relating to ~/.rocoto/rocotorc configuration file
* Increase reliability and performance of database and workflow locking
* Fix bug in Rocoto commands related to sourcing of shell init script
* Improve performance and reduce system load when monitoring for orphaned Rocoto processes
* Fix bug in XML validation that erroneously enforced ordering of metatask contents
* Fix bug in processing of XML special characters
* Fix task list update bug in rocotorewind
* Fix bug in rotocoboot that prevent task output files from being rotated
* Fix bugs in Cobalt batch system interface that were exposed in Ruby > 1.8.7
* Fix bug in LSF batch system interface related to long job names
* Add support for PBSPro batch system (e.g. for use on Cheyenne)
* Update libxml-ruby to version 3.0.0 to mitigate memory management bugs
* Add new cyclestring flags
  * @n = Number of days in the month
  * @o = All lower case abbreviated month name
  * @O = All lower case full month name
