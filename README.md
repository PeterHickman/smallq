# smallq

A classic wheel being reinvented. Queues are nice and all but seem to become massively over-engineered whilst still not allowing you to do quite what you wanted. Think of `SOAP` vs `REST`. `REST` will get the job done but you'll be saddled with `SOAP`

As this is just for myself I asked "How hard can this be?"

And now I am going to find out

## Usage

Messages are pushed onto the queue in the order they are received. They are read off in the same order, once read the server will discard the message. It is assumed that the client will take a significant amount of time to process the message compared to getting it from the queue (this is my use case here)

The server need not be blazingly fast and messages will be added to the queue at a similar rate that they are being consumed, the queues will never get too big (for some value of big, to be decided)

## Strategy

For the server to be robust and fast it will do the least to get the job done. Any line of code affects performance and can harbour bugs, so the less lines the better. The task of checking the format of the requests is handed off to the client code. It will validate that the request is correctly formatted and raise errors rather than sending it to the server for the server to validate and report the error back to the client

It means of course that the server is vulnerable to the client getting things wrong. But it is a valid trade-off

## The server configuration file

Everything is configured in the config file. Which is a simple YAML document with three sections

```yaml
server:
    host: localhost
    port: 2000
    cleanup_every: 15
    idle_for: 60
    daemon: true
logger:
    enabled: true
    path: ./server.log
    console: true
journal:
    enabled: true
    path: ./journal
    every: 60
```

### The `server` section

|Field|Values|
|---|---|
|`host`|The ip address or hostname of the server|
|`port`|The port that the server will accept connections on|
|`cleanup_every`|The housekeeping thread will kick in every `X` seconds|
|`idle_for`|If housekeeping detects a queue has been empty for `X` seconds or more it will be deleted|
|`daemon`|If `true` the process will run in background and override the `logger` settings. `console` will be set to false and `enabled` will be true. Make sure that `path` is a usable value. This way you can find the pid when you need to kill the process

### The `logger` section

|Field|Values|
|---|---|
|`enabled`|If `true` logs will be written to the file specified by the subsequent `path`field. If `false` no logging will be recorded|
|`path`|The filename that the logging will be written to if enabled|
|`console`|Regardless of the previous settings if `true` log messages will be written to the console|

### The `journal` section

|Field|Value|
|---|---|
|`enabled`|To enable journalling set this to `true`|
|`path`|If enabled journals will be written into this directory|
|`every`|A journal snapshot will be created every `X` seconds

## The client configuration file

An even simpler YAML document with just one section

```yaml
server:
    host: localhost
    port: 2000
```

### The `server` section

|Field|Values|
|---|---|
|`host`|The ip address or hostname of the server|
|`port`|The port that the server will accept connections on|

## Usage - the server

All you need to do, at this point, is run the server code

	$ ./smallq smallq.yml

If journalling is enabled and an existing journal is available this will be loaded so that the server can continue where it left off. Likewise should the server crash or be shutdown then it will try and write an journal before quitting. Once running it will take a snapshot of the current state of the system and all subsequent transactions will be written to a transactions file, then every `X` seconds (see the server config file `journal` > `every` setting) and new snapshot will be taken and a new transaction file opened

Old snapshots and transactions will be purged periodically

## Usage - the client
#### Queue names
Messages are added to named queues, the queue will be created once a message is added to it. Gets from non-existant queues will not create the queue. Queue names are 2 to 30 characters long consisting to `a-z`, upper and lower case, `0-9`, `-`, `_` and `.`. The range of valid characters may expand in the future

#### Message body
The message itself must be at least 1 character long. There is no upper limit. It can contain anything except `\n`, `\r`, `\f` or `\0`. If you are unsure of your message contents then either escape your message or use the `add64` and `get64` methods that will encode/decode you message with the existing Base64 module

### `add` and `add64`
```ruby
require 'smallq/client'
require 'smallq/config'

filename = ARGV[0]

config = Smallq::Config.load(filename)

c = Smallq::Client.new(config['server'])

r = c.add('queue_name', 'My first message')

r => {:status=>"OK", :id=>1542545179}
```

The `:status` should always be `OK` but check it anyway, the `:id` is the id that the message was given. It could be useful for logging should something go wrong but status is the important part

`add64` will encode the message body with the Base64 module. Remember to use the equivalent `get64` method or things will not make a lot of sense

### `get` and `get64`
```ruby
require 'smallq/client'
require 'smallq/config'

filename = ARGV[0]

config = Smallq::Config.load(filename)

c = Smallq::Client.new(config['server'])

r = c.get('queue_name')

r => {:status=>"OK", :id=>1542545179, :message=>"My first message"}
```
If there is something in the queue then `:status` will be `OK`, `:id` will be the same id as was given when the message was added and `:message` will be the original message. If the queue is empty or has not had anything added to it yet then `:status` will be `ERROR` and `:message` will be `QUEUE EMPTY`

Use the `get64` method to decode the messages that were sent with `add64`

### Stats
```ruby
require 'smallq/client'
require 'smallq/config'

filename = ARGV[0]

config = Smallq::Config.load(filename)

c = Smallq::Client.new(config['server'])

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
* The server has no concept of a user. If you can connect then you can add and get on any queue. If you cannot trust, or need to limit, your users then this system is not for you. I suspect that this is one of the places that the complexity of other implementations come from
* The message id is unique to the message regardless of the queue. It will be greater than the previous id. Each time the server starts it sets the first message id to the server's current time in seconds. Each subsequent id will be 1 more. If the server is restarted then there will be a gap in the ids. This is a cheap way of getting unique ids. Do not try and make use of this implementation detail
* The server is a monolith. It does not cluster, replicate, shard, federate or do the master slave thing. It will not scale beyond a single server
* If the client goes down before it processes the message the message is lost. This is probably the other source of complexity that other implementations have
