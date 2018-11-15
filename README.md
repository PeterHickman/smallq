# smallq

A classic wheel being reinvented. Queues are nice and all but seem to become massively over-engineered whilst still not allowing you to do quite what you want. Think of `SOAP` vs `REST`.`REST` will get the job done but you'll be saddled with `SOAP`

As this is just for myself I asked "How hard can this be?"

And now I am going to find out

## Strategy

The plan is for the server to be robust and fast. To this end it will do the least to get the job done. Any line of code affects performance and can harbour bugs, so the less lines the better. The task of checking the requests is being handed off to the client code. It will validate that the request is correctly formatted and give errors at that point rather than sending it to the server for the server to validate and report the error back to the client

It means of course that the server is vulnerable to the client getting things wrong. But it is a valid trade-off

## Limitations

* If the server goes down all the unread messages are lost
* Only one queue
* If the client goes down before it processes the message the message is lost

These things can be fixed
