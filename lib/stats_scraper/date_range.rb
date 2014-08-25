module StatsScraper
  class DateRange
    attr_reader :days

    def initialize(start_date, end_date)
      @days = []
      current_date = start_date
      while current_date <= end_date
        @days << Day.new(current_date)
        current_date += 1
      end

      StatsScraper.log('DateRange', "Built DateRange of length #{@days.length}.")
    end
  end
end
