require 'test_helper'

class DayTest < Minitest::Test
  def test_day_with_no_games_returns_properly
    @day = StatsScraper::Day.new(Date.new(2014, 8, 20))

    VCR.use_cassette('test_day_with_no_games_returns_properly') do
      assert_equal [], @day.games
    end
  end

  def test_day_with_games_returns_properly
    @day = StatsScraper::Day.new(Date.new(2014, 3, 1))
    expected = [
      2013020902,
      2013020903,
      2013020904,
      2013020905,
      2013020906,
      2013020907,
      2013020908,
      2013020909,
      2013020910,
      2013020911
    ]

    VCR.use_cassette('test_day_with_games_returns_properly') do
      assert_equal expected, @day.games.map(&:id)
    end
  end

  def test_day_with_unpersisted_games_inserts_correctly
    VCR.use_cassette('test_day_with_games_returns_properly') do
      date = Date.new(2014, 3, 1)
      @day = StatsScraper::Day.new(date)
      StatsScraper::DB.expects(:persisted_games_for_date).with(date).returns([]).once
      @day.games.each { |game| game.expects(:persist).once }

      @day.save_to_db
    end
  end

  def test_day_with_persited_game_only_persists_other_games
    VCR.use_cassette('test_day_with_games_returns_properly') do
      date = Date.new(2014, 3, 1)
      persisted_ids = [ 2013020902, 2013020906 ]
      @day = StatsScraper::Day.new(date)
      StatsScraper::DB.expects(:persisted_games_for_date).with(date).returns(persisted_ids).once

      @day.games.each do |game|
        if persisted_ids.include?(game.id)
          game.expects(:persist).never
        else
          game.expects(:persist).once
        end
      end

      @day.save_to_db
    end
  end
end
