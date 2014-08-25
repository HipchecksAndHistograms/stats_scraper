require 'test_helper'

class DayTest < Minitest::Test
  def test_gets_game_sheet
    @game = StatsScraper::Game.new("2013020902", Date.new(2014, 3, 1))

    VCR.use_cassette('test_gets_game_sheet') do
      assert_equal 306,                   @game.events.length
      assert_equal "WASHINGTON CAPITALS", @game.visiting_team
      assert_equal "BOSTON BRUINS",       @game.home_team
      assert_equal 17565,                 @game.attendance
      assert_equal "TD Garden",           @game.venue
    end
  end
end
