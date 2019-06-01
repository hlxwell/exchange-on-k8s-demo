task :default => :test
task :test do
  puts `cd auth-service && RACK_ENV=development rake`
  puts `cd trade-service && RACK_ENV=development rake`
  puts `cd order-service && RACK_ENV=development rake`
  puts `cd account-service && RACK_ENV=development rake`
end
