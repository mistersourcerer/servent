require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RuboCop::RakeTask.new do |task|
  task.fail_on_error = false
end

RSpec::Core::RakeTask.new(:spec)

task default: [:rubocop, :spec]
