require 'test_helper'

class ScraperTest < Minitest::Test
  def test_no_date_range_created_when_scraping_not_required
    StatsScraper::DB.stubs(:last_scraped_day).returns(Date.new(2014, 9, 20))
    Date.stubs(:today).returns(Date.new(2014, 9, 26))

    StatsScraper::DateRange.expects(:new).never
    StatsScraper::Logger.expects(:log).with("Scraper", "Scraping not required. Exiting.").once

    StatsScraper::Scraper.run
  end

  def test_date_range_created_when_scraping_is_required
    start_date = Date.new(2014, 9, 19)
    end_date = Date.new(2014, 9, 26)

    StatsScraper::DB.stubs(:last_scraped_day).returns(start_date)
    Date.stubs(:today).returns(end_date)

    date_range_mock = mock()
    date_range_mock.expects(:persist_days)

    StatsScraper::DateRange.expects(:new).with(start_date, end_date).returns(date_range_mock)

    StatsScraper::Scraper.run
  end
end
