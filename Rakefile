# frozen_string_literal: true

require 'rake/testtask'

# Some rake are optional and not installed on CI to speed things up.
# This helper will attempt to load the given file and run the logic
# in the given block if the load succeeded.
#
# @param [String]
def require_optional(file, &block)
  begin
    require file
  rescue LoadError
    return
  end
  block.call
end

Rake::TestTask.new do |task|
  task.libs << 'lib'
  task.libs << 'tests/helpers'
  task.pattern = 'tests/**/*_test.rb'
end
default_tasks = [:test]

require_optional('rubocop/rake_task') do
  RuboCop::RakeTask.new
  default_tasks << :rubocop
end

require_optional('yard') do
  YARD::Rake::YardocTask.new(:doc)

  # TODO: This appear to also generate the HTML output. So can this become `:doc`?
  YARD::Rake::YardocTask.new(:undoc) do |task|
    task.stats_options << '--list-undoc'
  end

  default_tasks << :undoc
end

task default: default_tasks
