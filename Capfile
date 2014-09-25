$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")
require 'stats_scraper'

require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/bundler'

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
