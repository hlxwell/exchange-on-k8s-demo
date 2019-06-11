task :default => :test
desc 'Test'
task :test do
  puts `cd db-migrator && RAILS_ENV=development rspec`
  puts `cd auth-service && RACK_ENV=development rake`
  puts `cd trade-service && RACK_ENV=development rake`
  puts `cd order-service && RACK_ENV=development rake`
  puts `cd user-service && RACK_ENV=development rake`
  puts `cd account-service && RACK_ENV=development rake`
end

desc 'Link Model'
task :link_model do
  puts `cd e2e-test && rm -rf models && mkdir models && ln ../models/* models/`
  puts `cd db-migrator && rm -rf app/models && mkdir -p app/models && ln ../models/* app/models/`
  puts `cd auth-service && rm -rf models && mkdir models && ln ../models/* models/`
  puts `cd trade-service && rm -rf models && mkdir models && ln ../models/* models/`
  puts `cd user-service && rm -rf models && mkdir models && ln ../models/* models/`
  puts `cd order-service && rm -rf models && mkdir models && ln ../models/* models/`
  puts `cd account-service && rm -rf models && mkdir models && ln ../models/* models/`
end

desc 'Bundle'
task :bundle do
  puts `cd auth-service && RACK_ENV=development bundle`
  puts `cd trade-service && RACK_ENV=development bundle`
  puts `cd order-service && RACK_ENV=development bundle`
  puts `cd user-service && RACK_ENV=development bundle`
  puts `cd account-service && RACK_ENV=development bundle`
end

desc 'Build and push docker'
task :build_and_push do
  # threads = []
  ["e2e-test", "db-migrator", "user-service", "auth-service", "trade-service", "order-service", "account-service"].each do |proj|
    # threads << Thread.new do
    IO.popen("docker build -t gcr.io/bitsx-vc-dev-poc/exchange-on-k8s/#{proj} ./#{proj}/", "r").each_line { |line| puts line }
    IO.popen("gcloud docker -- push gcr.io/bitsx-vc-dev-poc/exchange-on-k8s/#{proj}", "r").each_line { |line| puts line }
    # end
  end
  # threads.each &:join
end
