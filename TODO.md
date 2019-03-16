# Things to do

## General
* Use a proper testing framework

## Server
* Should do some logging - but just how much?
* Journalling to recover from crashes
* Configuration options
* The server to daemonise
* Purge inactive queues

## General notes

This was initially written in Ruby but some performance issues when running on OSX could not be resolved by fiddling with the code. I thought perhaps that GC was kicking in and freezing the application. But running the same code on Linux (Mint 18) did not exhibit the same behaviour, just some other oddities

So I rewrote it in Python to see of the same issues would appear. This would perhaps allow me to say this is either an OSX issue or perhaps a Ruby on OSX issue