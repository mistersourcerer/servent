require "bundler/setup"
require "servent"
require "webmock/rspec"

spec_dir = File.expand_path("../", __FILE__)
Dir["#{spec_dir}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
