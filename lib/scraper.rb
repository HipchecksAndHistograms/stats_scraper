module StatsScraper
  module Scraper
    def self.run
      StatsScraper::Day.new(Date.new(2013, 3, 1)).save_to_db
    end
  end
end
