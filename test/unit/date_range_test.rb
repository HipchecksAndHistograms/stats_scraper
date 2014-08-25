require 'test_helper'

class DateRangeTest < Minitest::Test
  def setup
    start_date, end_date = Date.new(2014, 1, 1), Date.new(2014, 1, 10)
    @range = StatsScraper::DateRange.new(start_date, end_date)
  end

  def test_date_range_is_correct_length
    assert_equal 10, @range.days.length
  end

  def test_date_range_scrapes_days
    VCR.use_cassette('test_date_range') do
      assert_equal 64, @range.days.map(&:games).flatten.count
    end
  end
end
