module StatsScraper
  class Event
    attr_reader :event_number,
                :period,
                :strength,
                :time_elapsed,
                :time_left,
                :event_name,
                :event_description,
                :visitor_on_ice,
                :home_on_ice

    def initialize(game_id, event_node)
      @game_id = game_id

      @event_number      = Integer(event_node.xpath("./td[1]").text)
      @period            = Integer(event_node.xpath("./td[2]").text)
      @strength          = event_node.xpath("./td[3]").text
      time_box           = event_node.xpath("./td[4]").children.map(&:text)
      @time_elapsed      = time_box.first
      @time_left         = time_box.last
      @event_name        = event_node.xpath("./td[5]").text
      @event_description = event_node.xpath("./td[6]").text

      @visitor_on_ice = parse_on_ice_table(event_node.xpath("./td[7]"))
      @home_on_ice    = parse_on_ice_table(event_node.xpath("./td[8]"))
    end

    def to_hash
      {
        game_id:           @game_id,
        event_number:      @event_number,
        period:            @period,
        strength:          @strength,
        time_elapsed:      @time_elapsed,
        time_left:         @time_left,
        event_name:        @event_name,
        event_description: @event_description
      }
    end

    def persist
      players_on_ice.each { |player| DB.insert_player_on_ice(player) }
      DB.insert_event(to_hash)
    end

    def players_on_ice
      @players_on_ice ||= begin
        players = [
          @visitor_on_ice.map { |player| merge_game_and_event_info(player, :visitor) },
          @home_on_ice.map { |player| merge_game_and_event_info(player, :home) }
        ]

        players.flatten
      end
    end

    private

    def merge_game_and_event_info(player, side)
      player.merge(game_id: @game_id, event_number: @event_number, side: side.to_s)
    end

    def parse_on_ice_table(on_ice_table)
      on_ice_table.xpath(".//td/table").map do |player|
        player_node = player.at_xpath(".//font")
        position, name = player_node.attributes["title"].value.split(" - ")
        number = player_node.text

        current_position = player.xpath(".//tr[2]/td").text

        { name: name, position: position, current_position: current_position, number: Integer(number) }
      end
    end
  end
end
