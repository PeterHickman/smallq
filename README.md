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

## Limitations and issues

* Only one queue
* Should do some logging
* If the server goes down all the unread messages are lost - needs journalling?
* If the client goes down before it processes the message the message is lost

These things can be fixed
