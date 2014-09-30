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
        events.each(&:persist)
        StatsScraper::Logger.log("Game", "Persisted #{events.count} events for game #{@id}.")
        DB.insert_game(to_hash)
        StatsScraper::Logger.log("Game", "Persisted game #{id}.")
      end

      private

      def to_hash
        {
          id:            @id,
          date:          @date,
          venue:         venue,
          attendance:    attendance,
          home_team:     home_team,
          visiting_team: visiting_team
        }
      end

      def information_box
        @information_box ||= game_sheet.xpath("//table[1]/tr[1]/td/table/tr/td/table/tr")
      end

      def game_sheet
        @game_sheet ||= begin
          StatsScraper::Logger.log("Game", "Downloading game #{@id} from day #{@date.to_s}.")
          game_sheet = self.class.get("/#{season}/PL#{web_id}.HTM")

          unless game_sheet.response.code == "200"
            StatsScraper::Logger.log("Game", "Invalid response code #{game_sheet.response.code} for game #{@id}!")
            raise InvalidResponse
          end
          @game_sheet = Nokogiri::HTML(game_sheet)
          StatsScraper::Logger.log("Game", "Downloaded #{@id} - #{visiting_team} vs. #{home_team}.")
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
        @attendance_row ||= information_box.xpath(".//table[@id='GameInfo']/tr[5]/td").text.match(/Attendance ([0-9,]*).at.(.+)/).captures
      end
    end
  end
end
