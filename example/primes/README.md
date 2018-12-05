# Prime numbers search

This example checks numbers for being primes. Start the server and kick off `make_work.rb` to create the available work. `do_work.rb` will process the available work and report all the primes that it finds. `report_work.rb` will report all the prime numbers that have been found

You only need one `make_work.rb` but you can have as many `do_work.rb` processes as you want (or your cpu can handle). You will probably need as many `report_work.rb` processes as `do_work.rb` processes

## `make_work.rb`
This process puts ranges of numbers onto the `available` queue. It initially dumps 40 ranges and then monitors the queue. When it falls below 20 it adds a further 40 ranges to keep things ticking over

## `do_work.rb`
Read the `available` queue and checks each number in the range to see if it is a prime. If it is a prime it posts the number onto the `results` queue. When it has completed checking the range it picks another range off the `available` queue

## `report_work.rb`
Read the `results` queue and diaplays the result
