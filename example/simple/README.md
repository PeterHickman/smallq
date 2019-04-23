# Simple examples

Just a simple test to throw data at the server and pull it all off again. Almost a denial of service attack to see what sort of load it will take. I've used this to check that the server is working correctly and that messages are written and read in the correct order

Fire up the server and let rip!

## `add.rb`

Sends the required number of messages to the queue `test_queue` in the format `Message X from PID` and a summary of how long it took

```bash
$ ./add.rb smallq.yml 1000
Message 1 from 5016
Message 2 from 5016
Message 3 from 5016
...
Message 998 from 5016
Message 999 from 5016
Message 1000 from 5016
Sent 1000 messages in 0.06809 seconds
That is 14686.4444118079 per second
$
```

## `get.rb`

Reads all the messages in the queue `test_queue` and displays them with a summary of how long it took

```bash
$ ./get.rb smallq.yml
Message 1 from 5016
Message 2 from 5016
Message 3 from 5016
...
Message 998 from 5016
Message 999 from 5016
Message 1000 from 5016
Read 1000 messages in 0.064864 seconds
That is 15416.872224963 per second
```
