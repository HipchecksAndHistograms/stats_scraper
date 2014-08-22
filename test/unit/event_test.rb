require 'test_helper'

class EventTest < Minitest::Test
  def test_gets_game_sheet
    @game = StatsScraper::Game.new("2013020902", Time.new(2014, 3, 1))

    VCR.use_cassette('test_gets_game_sheet') do
      assert_equal [1, 2, 3], @game.events.map(&:period).uniq
      assert_equal ["PSTR", "FAC", "HIT", "SHOT", "BLOCK", "STOP", "TAKE", "MISS", "PENL", "GIVE", "GOAL", "PEND", "GEND"], @game.events.map(&:event_name).uniq
      assert_equal (1..306).to_a, @game.events.map(&:event_number)

      boston_players = [
        "CHRIS KELLY",
        "CARL SODERBERG",
        "LOUI ERIKSSON",
        "MATT BARTKOWSKI",
        "JOHNNY BOYCHUK",
        "TUUKKA RASK",
        "PATRICE BERGERON",
        "BRAD MARCHAND",
        "REILLY SMITH",
        "DOUGIE HAMILTON",
        "ZDENO CHARA",
        "DAVID KREJCI",
        "JAROME IGINLA",
        "MILAN LUCIC",
        "TOREY KRUG",
        "KEVAN MILLER",
        "DANIEL PAILLE",
        "GREGORY CAMPBELL",
        "SHAWN THORNTON"
      ]

      washington_players = [
        "ERIC FEHR",
        "JOEL WARD",
        "JASON CHIMERA",
        "MIKE GREEN",
        "DMITRY ORLOV",
        "BRADEN HOLTBY",
        "NICKLAS BACKSTROM",
        "BROOKS LAICH",
        "ALEX OVECHKIN",
        "KARL ALZNER",
        "JOHN CARLSON",
        "JOHN ERSKINE",
        "CONNOR CARRICK",
        "CASEY WELLMAN",
        "MARCUS JOHANSSON",
        "TROY BROUWER",
        "JAY BEAGLE",
        "NICOLAS DESCHAMPS",
        "TOM WILSON"
      ]

      assert_equal boston_players, @game.events.map(&:home_on_ice).flatten.map { |p| p[:name] }.uniq
      assert_equal washington_players, @game.events.map(&:visitor_on_ice).flatten.map { |p| p[:name] }.uniq

      home_positions = ["Center", "Left Wing", "Defense", "Goalie", "Right Wing"]
      vistitor_positions = ["Right Wing", "Left Wing", "Defense", "Goalie", "Center"]
      assert_equal home_positions, @game.events.map(&:home_on_ice).flatten.map { |p| p[:position] }.uniq
      assert_equal vistitor_positions, @game.events.map(&:visitor_on_ice).flatten.map { |p| p[:position] }.uniq

      assert_equal [" ", "EV", "SH", "PP"], @game.events.map(&:strength).uniq

      assert @game.events.map(&:time_elapsed).none? { |t| t.nil? }
      assert @game.events.map(&:time_left).none? { |t| t.nil? }
      assert @game.events.map(&:event_description).none? { |t| t.nil? }
    end
  end
end
