module StatsScraper
  module Scraper
    def self.run
      start_date = DB.last_scraped_day || Date.new(2009, 9, 15)
      end_date = start_date + 7

      if end_date > Date.today
        StatsScraper.log("Scraper", "Scraping not required. Exiting.")
      else
        StatsScraper.log("Scraper", "Beginning scraping.")
        StatsScraper.log("Scraper", "#{(Date.today - start_date).to_i} days behind.")
        range = DateRange.new(start_date, end_date)
        range.persist_days
      end
    end
  end
end
