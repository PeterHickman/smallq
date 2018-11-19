def assert_equal(expected, actual, message = nil)
  $test_number = $test_number ? $test_number + 1 : 1

  text = message ? " - #{message}" : ''

  if expected == actual
    puts "#{$test_number}. Ok#{text}"
  else
    puts "#{$test_number}. Failed#{text}"
    puts "  Expected.: #{expected.inspect}"
    puts "  Actual...: #{actual.inspect}"
  end
end

def assert_raises(expection, message)
  begin
    yield
  rescue => e
    assert_equal(expection, e.class, message)
  end
end

def assert_doesnt_raise(message)
  begin
    yield
  rescue => e
    assert_equal(0, 1, "Raised #{e.class}")
  end

  assert_equal(1, 1, message)
end

def drain_queues(c)
  r = c.stats
  r.each do |q|
    if q[:size] == 0
      puts "Queue #{q[:queue_name]} is empty"
    else
      puts "Draining queue #{q[:queue_name]}"
      q[:size].times do
        c.get(q[:queue_name])
      end
    end
  end
end
