require 'test_helper'

class DayTest < Minitest::Test
  def test_day_with_no_games_returns_properly
    @day = StatsScraper::Day.new(Time.new(2014, 8, 20))

    VCR.use_cassette('test_day_with_no_games_returns_properly') do
      assert_equal [], @day.games
    end
  end

  def test_day_with_games_returns_properly
    @day = StatsScraper::Day.new(Time.new(2014, 3, 1))
    expected = [
      "2013020902",
      "2013020903",
      "2013020904",
      "2013020905",
      "2013020906",
      "2013020907",
      "2013020908",
      "2013020909",
      "2013020910",
      "2013020911"
    ]

    VCR.use_cassette('test_day_with_games_returns_properly') do
      assert_equal expected, @day.games
    end
  end
end
