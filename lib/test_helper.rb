def assert_equal(expected, actual)
  $test_number = $test_number ? $test_number + 1 : 1

  if expected == actual
    puts "#{$test_number}. Ok"
  else
    puts "#{$test_number}. Failed"
    puts "  Expected.: #{expected.inspect}"
    puts "  Actual...: #{actual.inspect}"
  end
end
