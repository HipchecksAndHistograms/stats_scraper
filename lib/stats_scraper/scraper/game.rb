module StatsScraper
  module Scraper
    class Game
      attr_reader :id,
                  :date

      include HTTParty
      base_uri 'http://www.nhl.com/scores/htmlreports/'

      def initialize(id, date)
        @id = id
        @date = date
      end

      def events
        @events ||= begin
          events = game_sheet.xpath("//tr[contains(@class, 'evenColor')]").map{ |event| Event.new(@id, event) }
          StatsScraper::Logger.log("Game", "Parsed #{events.length} events for game #{@id}.")
          events
        end
      end

      def visiting_team
        @visiting_team ||= team_name('Visitor')
      end

      def home_team
        @home_team ||= team_name('Home')
      end

      def attendance
        attendance = attendance_row[0].gsub(',', '')
        attendance.empty? ? nil : Integer(attendance)
      end

      def venue
        attendance_row[1]
      end

      def persist
        StatsScraper::Logger.log("Game", "Persisting game #{@id}.")
        DB.insert_events(events.map(&:to_hash))
        DB.insert_players_on_ice(events.map(&:players_on_ice).flatten)
        DB.insert_game(to_hash)
        StatsScraper::Logger.log("Game", "Persisted game #{@id}.")

        true
      rescue => e
        anomaly = "Unable to persist game #{@id}: #{e}"
        StatsScraper::Logger.log("Game", anomaly)
        DB.remove_game_from_db(@id)
        DB.insert_anomaly(@id, "Game", anomaly)

        false
      end

      def game_sheet_date
        @game_sheet_date ||= Date.strptime(information_box.xpath(".//table[@id='GameInfo']/tr[4]/td").text, '%a, %b %d, %Y')
      end

      def valid?
        errors.none? { |key, value| value }
      end

      def errors
        @errors ||= begin
          errors = {}
          errors.merge('scraped day doesn\'t match game sheet date' => scraped_day_doesnt_match_game_sheet_date)
          errors.merge('information box isn\'t present' => information_box_isnt_present)
        end
      end

      private

      def scraped_day_doesnt_match_game_sheet_date
        date != game_sheet_date
      rescue
        nil
      end

      def information_box_isnt_present
        information_box.nil?
      rescue
        nil
      end

      def to_hash
        {
          game_id:       @id,
          date:          @date,
          venue:         venue,
          attendance:    attendance,
          home_team:     home_team,
          visiting_team: visiting_team
        }
      end

      def information_box
        @information_box ||= game_sheet.at_xpath("//table[1]/tr[1]/td/table/tr/td/table/tr")
      end

      def game_sheet
        @game_sheet ||= begin
          get_url = "/#{season}/PL#{web_id}.HTM"
          StatsScraper::Logger.log("Game", "Downloading game #{@id} from day #{@date.to_s}. URL: #{self.class.base_uri}#{get_url}")
          game_sheet = self.class.get(get_url)

          unless game_sheet.response.code == "200"
            StatsScraper::Logger.log("Game", "Invalid response code #{game_sheet.response.code} for game #{@id}!")
            raise InvalidResponse
          end
          @game_sheet = Nokogiri::HTML(game_sheet)
          StatsScraper::Logger.log("Game", "Downloaded #{@id}.")
          @game_sheet
        end
      end

      def season_start_year
        @date.month > 8 ? @date.year : @date.year - 1
      end

      def web_id
        @id.to_s[4..-1]
      end

      def season
        "#{season_start_year}#{season_start_year + 1}"
      end

      def team_name(side)
        information_box.xpath(".//table[@id='#{side}']/tr[3]/td").children.first.text
      end

      def attendance_row
        @attendance_row ||= information_box.xpath(".//table[@id='GameInfo']/tr[5]/td").text.match(/Attendance ?([0-9,]*).at.(.+)/).captures
      end
    end
  end
end
