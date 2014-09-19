module StatsScraper
  class Day
    include HTTParty
    base_uri "http://www.nhl.com/ice/scores.htm"

    def initialize(date = Date.today)
      StatsScraper.log("Day", "Creating day for #{date}")
      @date = date
      @options = { query: { date: formatted_date }}
    end

    def games
      @games ||= begin
        links = score_box.xpath("//div[contains(@class, 'gcLinks')]/div[2]/a[1]/@href").map(&:value)
        StatsScraper.log("Day", "Found #{links.length} games on day #{@date}.")
        links.map { |link| CGI.parse(URI.parse(link).query)['id'].first }.map { |id| Game.new(Integer(id), @date) }
      end
    end

    def save_to_db
      StatsScraper::DB.database.transaction do
        StatsScraper.log("Day", "Inserting #{games.count} games for day #{@date}.")
        games.map(&:to_hash).each do |game|
          events = game.delete(:events)

          StatsScraper.log("Day", "Inserting game #{game[:id]}.")
          StatsScraper::DB.insert_game(game)
          StatsScraper.log("Day", "Successfully inserted game #{game[:id]}.")
          StatsScraper.log("Day", "Inserting #{events.count} events for game #{game[:id]}.")
          events.each do |event|
            players_on_ice = event.delete(:players_on_ice)
            StatsScraper::DB.insert_event(event)
            players_on_ice.each { |player| StatsScraper::DB.insert_player_on_ice(player) }
          end
          StatsScraper.log("Day", "Succesfully inserted #{events.count} events for game #{game[:id]}.")
        end
        StatsScraper.log("Day", "Succesfully inserted #{games.count} games for day #{@date}.")
      end
    end

    private

    def score_box
      selected = page.xpath("//*[@id=\"scoresBody\"]")
      raise InvalidResponse if selected.length != 1
      selected.first
    end

    def page
      StatsScraper.log("Day", "Downloading games for #{@date}.")
      page = self.class.get("", @options)

      unless page.response.code == "200"
        StatsScraper.log("Day", "Invalid response code #{page.response.code} for #{@date}!")
        raise InvalidResponse
      end
      Nokogiri::HTML(page)
    end

    def formatted_date
      @date.strftime("%m/%d/%Y")
    end
  end
end
