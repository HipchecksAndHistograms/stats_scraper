module StatsScraper
  module Scraper
    def self.run
      start_date = DB.last_scraped_day || Date.new(2010, 9, 21)
      end_date = start_date + 7

      if end_date > Date.today
        StatsScraper::Logger.log("Scraper", "Scraping not required. Exiting.")
      else
        StatsScraper::Logger.log("Scraper", "Beginning scraping.")
        StatsScraper::Logger.log("Scraper", "#{(Date.today - start_date).to_i} days behind.")
        range = DateRange.new(start_date, end_date)
        range.persist_days
      end
    end
  end
end
