module StatsScraper
  class DateRange
    attr_reader :days

    def initialize(start_date, end_date)
      @days = []
      current_date = start_date
      while current_date <= end_date
        @days << Scraper::Day.new(current_date)
        current_date += 1
      end

      StatsScraper::Logger.log('DateRange', "Built DateRange of length #{@days.length}.")
    end

    def persist_days
      @days.each { |day| day.save_to_db }
    end
  end
end
