module StatsScraper
  class Game
    include HTTParty
    base_uri 'http://www.nhl.com/scores/htmlreports/'

    def initialize(id, date)
      @id = id
      @date = date
    end

    def events
      @events ||= game_sheet.xpath("/html/body/table/tr[contains(@class, 'evenColor')]").map{ |e| Event.new(Nokogiri::HTML(e.to_html)) }
    end

    def visiting_team
      @visiting_team ||= team_name('Visitor')
    end

    def home_team
      @home_team ||= team_name('Home')
    end

    def attendance
      Integer(attendance_row[0].gsub(',', ''))
    end

    def venue
      attendance_row[1]
    end

    private

    def information_box
      @information_box ||= Nokogiri::HTML(game_sheet.xpath("/html/body/table[1]/tr[1]/td/table/tr/td/table/tr").to_html)
    end

    def game_sheet
      @game_sheet ||= Nokogiri::HTML(self.class.get("/#{season}/PL#{web_id}.HTM"))
    end

    def season_start_year
      @date.month > 8 ? @date.year : @date.year - 1
    end

    def web_id
      @id[4..-1]
    end

    def season
      "#{season_start_year}#{season_start_year + 1}"
    end

    def team_name(side)
      information_box.xpath("//table[@id='#{side}']/tr[3]/td").children.first.text
    end

    def attendance_row
      @attendance_row ||= information_box.xpath("//table[@id='GameInfo']/tr[5]/td").text.match(/Attendance ([0-9,]+).at.(.+)/).captures
    end
  end
end
