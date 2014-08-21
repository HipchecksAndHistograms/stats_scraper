$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_test.rb'
end

task default: [:test]
