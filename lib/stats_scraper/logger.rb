require 'logger'

module StatsScraper
  module Logger
    def self.logger
      @logger ||= ::Logger.new(STDOUT)
    end

    def self.log(progname, message)
      self.logger.add(::Logger::INFO, message, progname) unless StatsScraper.test?
    end
  end
end
