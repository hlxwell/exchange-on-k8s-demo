[
  ["sample1@gmail.com", "fejkljr2ijfi"],
  ["sample2@gmail.com", "jd873kdufidj"],
].each do |email, password|
  print "creating #{email}"
  if User.register(email, password)
    puts "...success"
  else
    puts "...failed"
  end
end
