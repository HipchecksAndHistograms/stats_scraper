require 'date'
require 'stats_scraper/logger'

require 'httparty'
require 'nokogiri'

require 'stats_scraper/scraper/day'
require 'stats_scraper/scraper/game'
require 'stats_scraper/scraper/event'
require 'stats_scraper/date_range'

require 'db'
require 'scraper'

module StatsScraper
  class InvalidResponse < StandardError; end

  def self.environment(env = :get_env)
    if env == :get_env
      if @environment
      elsif ENV["STATS_SCRAPER_ENV"].nil?
        @environment = 'development'
      else
        @environment = ENV["STATS_SCRAPER_ENV"]
      end
    else
      @environment = env.to_s
    end

    return @environment
  end

  def self.test?
    self.environment == 'test'
  end

  def self.config
    @config ||= begin
      YAML.load_file("config/config.yml")[environment]
    end
  end
end
