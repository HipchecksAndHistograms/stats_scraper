module StatsScraper
  module Scraper
    class Day
      include HTTParty
      base_uri "http://www.nhl.com/ice/scores.htm"

      def initialize(date = Date.today)
        StatsScraper::Logger.log("Day", "Creating day for #{date}")
        @date = date
        @options = { query: { date: formatted_date }}
      end

      def games
        @games ||= begin
          links = score_box.xpath("//div[contains(@class, 'gcLinks')]/div[2]/a[1]/@href").map(&:value)
          StatsScraper::Logger.log("Day", "Found #{links.length} games on day #{@date}.")
          links.map { |link| CGI.parse(URI.parse(link).query)['id'].first }.map { |id| Game.new(Integer(id), @date) }
        end
      end

      def save_to_db
        StatsScraper::Logger.log("Day", "Inserting #{games.count} games for day #{@date}.")
        persisted_games_for_date = DB.persisted_game_ids_for_date(@date)
        StatsScraper::Logger.log("Day", "#{persisted_games_for_date.count} games for #{@date} already persisted.") if persisted_games_for_date.count > 0
        games_to_insert = games.select { |game| !persisted_games_for_date.include?(game.id) }
        games_to_insert.each { |game| game.persist }
        StatsScraper::Logger.log("Day", "Succesfully inserted #{games_to_insert.count} games for day #{@date}.")
      end

      private

      def score_box
        selected = page.xpath("//*[@id=\"scoresBody\"]")
        raise InvalidResponse if selected.length != 1
        selected.first
      end

      def page
        StatsScraper::Logger.log("Day", "Downloading games for #{@date}.")
        page = self.class.get("", @options)

        unless page.response.code == "200"
          StatsScraper::Logger.log("Day", "Invalid response code #{page.response.code} for #{@date}!")
          raise InvalidResponse
        end
        Nokogiri::HTML(page)
      end

      def formatted_date
        @date.strftime("%m/%d/%Y")
      end
    end
  end
end
