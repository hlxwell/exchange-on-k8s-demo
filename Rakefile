task :default => :test
task :test do
  puts `cd db-migrator && RAILS_ENV=development rspec`
  puts `cd auth-service && RACK_ENV=development rake`
  puts `cd trade-service && RACK_ENV=development rake`
  puts `cd order-service && RACK_ENV=development rake`
  puts `cd account-service && RACK_ENV=development rake`
end

task :link_model do
  puts `cd db-migrator && rm -rf app/models && mkdir -p app/models && ln ../models/* app/models/`
  puts `cd auth-service && rm -rf models && mkdir models && ln ../models/* models/`
  puts `cd trade-service && rm -rf models && mkdir models && ln ../models/* models/`
  puts `cd order-service && rm -rf models && mkdir models && ln ../models/* models/`
  puts `cd account-service && rm -rf models && mkdir models && ln ../models/* models/`
end

task :bundle do
  puts `cd auth-service && RACK_ENV=development bundle`
  puts `cd trade-service && RACK_ENV=development bundle`
  puts `cd order-service && RACK_ENV=development bundle`
  puts `cd account-service && RACK_ENV=development bundle`
end
