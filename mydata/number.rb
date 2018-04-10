count = 1
File.open("number.txt", "w") do |text|
  10000000.times do |number|
    number += 1
    text.puts(number.to_s)
  end
end
