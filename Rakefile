$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")

require 'rake'
require 'rake/testtask'
require 'stats_scraper'

Rake::TestTask.new do |t|
  t.libs.push 'test'
  t.pattern = 'test/**/*_test.rb'
end

namespace :db do
  desc "setup db"
  task :setup do
    StatsScraper::DB.setup
  end
end

namespace :scraper do
  desc "run scraper"
  task :run do
    StatsScraper::Scraper.run
  end
end

task default: [:test]
