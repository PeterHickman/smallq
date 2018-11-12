# smallq

A classic wheel being reinvented. Queues are nice and all but seem to become massively over-engineered whilst still not allowing you to do quite what you want. Think of `SOAP` vs `REST`.`REST` will get the job done but you'll be saddled with `SOAP`

As this is just for myself I asked "How hard can this be?"

And now I am going to find out

## Limitations

* If the server goes down all the unread messages are lost
* Only one queue
* If the client goes down before it processes the message the message is lost

These things can be fixed

