require 'date'
require 'logger'

require 'httparty'
require 'nokogiri'

require 'stats_scraper/day'
require 'stats_scraper/game'
require 'stats_scraper/event'
require 'stats_scraper/date_range'

module StatsScraper
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.log(progname, message)
    self.logger.add(Logger::INFO, message, progname) unless self.test?
  end

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
end
