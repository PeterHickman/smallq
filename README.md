# smallq

A classic wheel being reinvented. Queues are nice and all but seem to become massively over-engineered whilst still not allowing you to do quite what you wanted. Think of `SOAP` vs `REST`.`REST` will get the job done but you'll be saddled with `SOAP`

As this is just for myself I asked "How hard can this be?"

And now I am going to find out

## Usage

Messages are pushed onto the queue in the order they are received. They are read off in the same order, once read the server will discard the message. It is assumed that the client will take a significant amount of time to process the message compared to getting it from the queue (this is my use case here)

The server need not be blazingly fast and messages will be added to the queue at a similar rate that they are being consumed, the queues will never get too big (for some value of big, to be decided)

## Strategy

For the server to be robust and fast it will do the least to get the job done. Any line of code affects performance and can harbour bugs, so the less lines the better. The task of checking the format of the requests is handed off to the client code. It will validate that the request is correctly formatted and raise errors rather than sending it to the server for the server to validate and report the error back to the client

It means of course that the server is vulnerable to the client getting things wrong. But it is a valid trade-off

## Usage - the server

All you need to do, at this point, is run the server code

	$ ./server.rb
The host is hardcoded as `localhost` and the port to `2000`

## Usage - the client
Messages are added to named queues, the queue will be created once a message is added to it. Gets from non-existant queues will not create the queue. Queue names are 2 to 30 characters long consisting to `a-z`, upper and lower case, `0-9`, `-`, `_` and `.`. The range of valid characters may expand in the future

There are all of three commands
### Add
```ruby
require 'smallq/client'

c = Smallq::Client.new('localhost', 2000)

r = c.add('queue_name', 'My first message')

r => {:status=>"OK", :id=>1542545179}
```

The `:status` should always be`OK` but check it anyway, the `:id` is the id that the message was given. It could be useful for logging should something go wrong but status is the important part
### Get
```ruby
require 'smallq/client'

c = Smallq::Client.new('localhost', 2000)

r = c.get('queue_name')

r => {:status=>"OK", :id=>1542545179, :message=>"My first message"}
```
If there is something in the queue then `:status` will be `OK`, `:id` will be the same id as was given when the message was added and `:message` will be the original message. If the queue is empty or has not had anything added to it yet then `:status` will be `ERROR` and `:message` will be `QUEUE EMPTY`
### Stats
```ruby
require 'smallq/client'

c = Smallq::Client.new('localhost', 2000)

r = c.stats

r => [
  {:queue_name=>"general", :adds=>51, :gets=>51, :size=>0, :last_used=>1542545655}
  {:queue_name=>"tom", :adds=>10, :gets=>10, :size=>0, :last_used=>1542545651}
  {:queue_name=>"fred", :adds=>10, :gets=>10, :size=>0, :last_used=>1542545655}
]
```
This returns a list of all the known queues (those that have had messages added to them) and their stats

* `:queue_name` The name of the queue
* `:adds` The number of messages that have been added to the queue
* `:gets` The number of messages that have been read from the queue
* `:size` The number of messages currently in the queue
* `:last_used` The last time that the queue was added to or read from

## Limitations and issues

### Server
* Should do some logging
* Journalling to recover from crashes
* Configuration options
* The server to daemonise
* Purge inactive queues

### Client
* If the client goes down before it processes the message the message is lost

These things can be fixed, perhaps
