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

  desc "run scraper for day"
  task :run_for_day do
    StatsScraper::Scraper.run_for_day
  end

  desc "run scraper for game"
  task :run_for_game do
    StatsScraper::Scraper.run_for_game
  end
end

task default: [:test]
