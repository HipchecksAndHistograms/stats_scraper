require 'test_helper'

class DateRangeTest < Minitest::Test
  def setup
    start_date, end_date = Date.new(2014, 1, 1), Date.new(2014, 1, 2)
    @range = StatsScraper::DateRange.new(start_date, end_date)
  end

  def test_date_range_is_correct_length
    assert_equal 2, @range.days.length
  end

  def test_date_range_scrapes_days
    VCR.use_cassette('test_date_range') do
      assert_equal 12, @range.days.map(&:games).flatten.count
      assert_equal 3730, @range.days.map(&:games).flatten.map(&:events).flatten.count
    end
  end
end
