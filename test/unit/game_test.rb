require 'test_helper'

class GameTest < Minitest::Test
  def test_gets_game_sheet
    VCR.use_cassette('test_gets_game_sheet') do
      @game = StatsScraper::Scraper::Game.new(2013020902, Date.new(2014, 3, 1))

      assert_equal 306,                   @game.events.length
      assert_equal "WASHINGTON CAPITALS", @game.visiting_team
      assert_equal "BOSTON BRUINS",       @game.home_team
      assert_equal 17565,                 @game.attendance
      assert_equal "TD Garden",           @game.venue
    end
  end

  def test_persists_correctly
    VCR.use_cassette('test_persists_correctly') do
      date = Date.new(2014, 3, 1)
      @game = StatsScraper::Scraper::Game.new(2013020902, date)

      game_hash = {
        game_id:       2013020902,
        date:          date,
        venue:         'TD Garden',
        attendance:    17565,
        home_team:     'BOSTON BRUINS',
        visiting_team: 'WASHINGTON CAPITALS'
      }

      StatsScraper::DB.expects(:insert_events).once
      StatsScraper::DB.expects(:insert_players_on_ice).once
      StatsScraper::DB.expects(:insert_game).with(game_hash).once

      assert @game.persist
    end
  end

  def test_game_that_fails_to_persist_removes_database_entries
    VCR.use_cassette('test_game_that_fails_to_persist_removes_database_entries') do
      date = Date.new(2014, 3, 1)
      @game = StatsScraper::Scraper::Game.new(2013020902, date)

      StatsScraper::DB.expects(:insert_events).once
      StatsScraper::DB.expects(:insert_players_on_ice).once
      StatsScraper::DB.expects(:insert_game).once.raises(NoMethodError)
      StatsScraper::DB.expects(:remove_game_from_db).with(@game.id).once.returns(nil)
      StatsScraper::DB.expects(:insert_anomaly).once.returns(nil)

      assert !@game.persist
    end
  end

  def test_game_with_no_attendance_parses_correctly
    VCR.use_cassette('test_game_with_no_attendance_parses_correctly') do
      @game_with_no_attendance_number = StatsScraper::Scraper::Game.new(2010010006, Date.new(2010, 9, 21))

      assert_equal 328,                   @game_with_no_attendance_number.events.length
      assert_equal "OTTAWA SENATORS",     @game_with_no_attendance_number.visiting_team
      assert_equal "TORONTO MAPLE LEAFS", @game_with_no_attendance_number.home_team
      assert_equal nil,                   @game_with_no_attendance_number.attendance
      assert_equal "Air Canada Centre",   @game_with_no_attendance_number.venue
    end
  end
end
