# Things to do

## General
* Use a proper testing framework
* Should the house keeping thread move into the QueueManager?

## Server
* Journalling to recover from crashes
  * <s>Purge old files from journal</s>
  * <s>Mutex to stop transactions being corrupted</s>
  * <s>Write snapshot on server exit</s>
  * <s>Determine better sleep time for `wait_for_transaction`</s>
  * <s>Some metrics perhaps</s>
* The server to daemonise
