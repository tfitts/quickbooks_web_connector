# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb", __FILE__)

$dir = File.dirname(File.expand_path(__FILE__))

require 'rspec/rails'
require 'rexml/document'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support and it's subdirectories
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    # Make sure we can run redis
    if !system("which redis-server")
      puts '', "** can't find `redis-server` in your path"
      abort ''
    end

    # Start redis
    puts "Starting redis for testing at localhost:9736"
    `redis-server #{$dir}/support/redis/redis-test.conf`
    QuickbooksWebConnector.redis = 'localhost:9736'
  end

  config.before(:each) do
    QuickbooksWebConnector.redis.flushall
  end

  # Kill our own redis we started
  config.after(:suite) do
    processes = `ps -A -o pid,command | grep [r]edis-test`.split($/)
    pids = processes.map { |process| process.split(" ")[0] }
    puts "Killing test redis server..."
    pids.each { |pid| Process.kill("TERM", pid.to_i) }
    system("rm -f #{$dir}/support/redis/dump.rdb")
  end
end
