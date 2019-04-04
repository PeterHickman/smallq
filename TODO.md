# Things to do

## General
* Use a proper testing framework
* Should the house keeping thread move into the QueueManager?

## Server
* Journalling to recover from crashes
  * Purge old files
  * Mutex to stop transactions being corrupted
  * Write snapshot on server exit
* The server to daemonise
