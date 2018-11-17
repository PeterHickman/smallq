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
