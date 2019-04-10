# Things to do

## General
* Use a proper testing framework
* Should the house keeping thread move into the QueueManager?

## Server
* Journalling to recover from crashes
  * Purge old files with snapshot
  * <s>Mutex to stop transactions being corrupted</s>
  * <s>Write snapshot on server exit</s>
  * Determine better sleep time for `wait_for_transaction` (config option?)
  * Some metrics perhaps
* The server to daemonise
