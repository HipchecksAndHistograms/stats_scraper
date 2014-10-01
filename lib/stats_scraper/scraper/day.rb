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
          links = page.xpath(".//div[contains(@class, 'gcLinks')]/div[2]/a[1]/@href").map(&:value)
          StatsScraper::Logger.log("Day", "Found #{links.length} games on day #{@date}.")
          links = links.map { |link| Integer(CGI.parse(URI.parse(link).query)['id'].first) }
          StatsScraper::Logger.log("Day", "Creating games for each of #{links.join(',')}.")
          games = links.map { |id| Game.new(id, @date) }

          games.select do |game|
            if game.date == game.game_sheet_date
              true
            else
              anomaly = "Game requested for date #{game.date} but game sheet says date was #{game.game_sheet_date}."
              StatsScraper::Logger.log("Day", anomaly)
              StatsScraper::DB.insert_anomaly(game.id, "Game", anomaly)
            end
          end
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

      def page
        @page ||= begin
          StatsScraper::Logger.log("Day", "Downloading games for #{@date}.")
          page = self.class.get("", @options)

          unless page.response.code == "200"
            StatsScraper::Logger.log("Day", "Invalid response code #{page.response.code} for #{@date}!")
            raise InvalidResponse
          end
          StatsScraper::Logger.log("Day", "Downloaded games for #{@date}. URL: #{page.request.last_uri.to_s}")
          Nokogiri::HTML(page)
        end
      end

      def formatted_date
        @date.strftime("%m/%d/%Y")
      end
    end
  end
end
