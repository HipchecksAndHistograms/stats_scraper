module StatsScraper
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
        StatsScraper.log("Day", "Found #{links.length} games on day #{@date}.")
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
