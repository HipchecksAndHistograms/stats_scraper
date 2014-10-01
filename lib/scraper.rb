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

    def self.run_for_day
      day = ENV['day']

      if day.nil?
        StatsScraper::Logger.log("Scraper", "No day provided. Exiting.")
      else
        StatsScraper::Logger.log("Scraper", "Running scraper for #{day}.")
        day = Day.new(day)
        day.save_to_db
      end
    end

    def self.run_for_game
      game_id = ENV['game_id']
      date = Date.parse(ENV['date'])

      if game_id.nil?
        StatsScraper::Logger.log("Scraper", "No game_id provided. Exiting.")
      elsif date.nil?
        StatsScraper::Logger.log("Scraper", "No day provided. Exiting.")
      else
        game = Game.new(game_id, date)
        game.persist
      end
    end
  end
end
