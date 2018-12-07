# Prime numbers search

This example searches for prime numbers. Start the server and kick off `make_work.rb` to create the available work. `do_work.rb` will process the available work and post all the primes that it finds. `report_work.rb` will report all the prime numbers that have been found

You only need one `make_work.rb` but you can have as many `do_work.rb` processes as you want (or your cpu can handle). You can get away with less `report_work.rb` processes than `do_work.rb` processes

This is really a semi-realistic test to put the server under presure. Which is not how I plan to use it but it's always a good idea to see what happends when you abuse a system

## `make_work.rb`
This puts ranges of numbers onto the `available` queue. It initially dumps 40 ranges and then monitors the queue. When it falls below 20 it adds a further 40 ranges to keep things ticking over

You can provide it with a command line argument that is the total number of work units to produce. It will quit once it has put this many on the queue. The default value is 40

## `do_work.rb`
Read the `available` queue and checks each number in the range to see if it is a prime. If it is a prime it posts the number onto the `results` queue. When it has completed checking the range it picks another range off the `available` queue

## `report_work.rb`
Read the `results` queue and displays the result
