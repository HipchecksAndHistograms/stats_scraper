require 'sequel'

module StatsScraper
  module DB
    def self.database
      if @database.nil? || !@database.test_connection
        StatsScraper::Logger.log("DB", "Creating new database connection.")
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
        primary_key :game_id
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

      database.drop_table? :anomalies
      database.create_table :anomalies do
        String :id
        String :type
        String :description
      end
    end

    def self.insert_game(game)
      database[:games].insert(game)
      database[:anomalies].where(type: "Game", id: game[:game_id]).delete
    end

    def self.insert_events(events)
      database[:events].multi_insert(events)
    end

    def self.insert_players_on_ice(players_on_ice)
      database[:players_on_ice].multi_insert(players_on_ice)
    end

    def self.insert_anomaly(id, type, description)
      database[:anomalies].insert(id: id, type: type, description: description)
    end

    def self.remove_game_from_db(id)
      database[:events].where(game_id: id).delete
      database[:players_on_ice].where(game_id: id).delete
      database[:games].where(game_id: id).delete
    end

    def self.persisted_game_ids_for_date(date)
      ids = database[:games].select(:game_id).where(date: date).to_a.map { |g| g[:game_id] }
      StatsScraper::Logger.log("DB", "Found #{ids.count} persisted games for date #{date}.")
      ids
    end

    def self.last_scraped_day
      db_day = database[:games].select(:date).order(Sequel.desc(:date)).limit(1).first
      db_day.nil? ? nil : db_day[:date]
    end
  end
end
