require 'sequel'

module StatsScraper
  module DB
    def self.database
      if @database.nil? || !@database.test_connection
        StatsScraper.log("DB", "Creating new database connection.")
        @database = Sequel.postgres("stats_scraper_#{StatsScraper.environment}",
                                    user:     StatsScraper.config['database_user'],
                                    password: StatsScraper.config['database_password'],
                                    host:     StatsScraper.config['database_host'],
                                    port:     StatsScraper.config['database_port'])
      else
        @database
      end
    end

    def self.setup
      database.drop_table? :games
      database.create_table :games do
        primary_key :id
        Date        :date
        String      :venue
        Integer     :attendance
        String      :home_team
        String      :visiting_team
      end

      database.drop_table? :events
      database.create_table :events do
        Integer :game_id
        Integer :event_number
        Integer :period
        String  :strength
        String  :time_elapsed
        String  :time_left
        String  :event_name
        String  :event_description
      end

      database.drop_table? :players_on_ice
      database.create_table :players_on_ice do
        Integer :game_id
        Integer :event_number
        String  :side
        String  :name
        String  :position
        String  :current_position
        Integer :number
      end
    end

    def self.insert_game(game)
      database[:games].insert(game)
    end

    def self.insert_event(event)
      database[:events].insert(event)
    end

    def self.insert_player_on_ice(player_on_ice)
      database[:players_on_ice].insert(player_on_ice)
    end

    def self.persisted_game_ids_for_date(date)
      ids = database[:games].select(:id).where(date: date).to_a.map { |g| g[:id] }
      StatsScraper.log("DB", "Found #{ids.count} persisted games for date #{date}.")
      ids
    end

    def self.last_scraped_day
      database[:games].select(:date).order(Sequel.desc(:date)).limit(1).first[:date]
    end
  end
end
