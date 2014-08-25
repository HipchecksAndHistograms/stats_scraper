module StatsScraper
  class InvalidResponse < StandardError; end

  class Day
    include HTTParty
    base_uri "http://www.nhl.com/ice/scores.htm"

    def initialize(date = Date.today)
      @date = date
      @options = { query: { date: formatted_date }}
    end

    def games
      @games ||= begin
        links = score_box.xpath("//div[contains(@class, 'gcLinks')]/div[2]/a[1]/@href").map(&:value)
        links.map { |link| CGI.parse(URI.parse(link).query)['id'].first }.map { |id| Game.new(id, @date) }
      end
    end

    private

    def score_box
      selected = page.xpath("//*[@id=\"scoresBody\"]")
      raise InvalidResponse if selected.length != 1
      selected.first
    end

    def page
      Nokogiri::HTML(self.class.get("", @options))
    end

    def formatted_date
      @date.strftime("%m/%d/%Y")
    end
  end
end
