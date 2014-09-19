require 'minitest/autorun'
require 'mocha/mini_test'
require 'vcr'
require 'stats_scraper'

StatsScraper.environment(:test)

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  c.hook_into :webmock
end
