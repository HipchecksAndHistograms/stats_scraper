$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")

require 'rake'
require 'rake/testtask'
require 'stats_scraper'

Rake::TestTask.new do |t|
  t.libs.push 'test'
  t.pattern = 'test/**/*_test.rb'
end

task default: [:test]
