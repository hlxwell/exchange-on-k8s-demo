task :default => :test
task :test do
  puts `cd db-migrator && RAILS_ENV=development rspec`
  puts `cd auth-service && RACK_ENV=development rake`
  puts `cd trade-service && RACK_ENV=development rake`
  puts `cd order-service && RACK_ENV=development rake`
  puts `cd account-service && RACK_ENV=development rake`
end

task :bundle do
  puts `cd auth-service && RACK_ENV=development bundle`
  puts `cd trade-service && RACK_ENV=development bundle`
  puts `cd order-service && RACK_ENV=development bundle`
  puts `cd account-service && RACK_ENV=development bundle`
end
