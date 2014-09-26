require 'test_helper'

class DayTest < Minitest::Test
  def test_gets_game_sheet
    @game = StatsScraper::Scraper::Game.new(2013020902, Date.new(2014, 3, 1))

    VCR.use_cassette('test_gets_game_sheet') do
      assert_equal 306,                   @game.events.length
      assert_equal "WASHINGTON CAPITALS", @game.visiting_team
      assert_equal "BOSTON BRUINS",       @game.home_team
      assert_equal 17565,                 @game.attendance
      assert_equal "TD Garden",           @game.venue
    end
  end

  def test_persists_correctly
    VCR.use_cassette('test_gets_game_sheet') do
      date = Date.new(2014, 3, 1)
      @game = StatsScraper::Scraper::Game.new(2013020902, date)

      game_hash = {
        id:            2013020902,
        date:          date,
        venue:         'TD Garden',
        attendance:    17565,
        home_team:     'BOSTON BRUINS',
        visiting_team: 'WASHINGTON CAPITALS'
      }

      StatsScraper::DB.expects(:insert_game).with(game_hash).once
      @game.events.each { |event| event.expects(:persist) }

      @game.persist
    end
  end
end
