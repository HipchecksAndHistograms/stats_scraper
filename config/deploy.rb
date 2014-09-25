lock '3.2.1'

set :application, 'stats_scraper'
set :repo_url, 'git@github.com:HipchecksAndHistograms/stats_scraper.git'
set :deploy_to, StatsScraper.config['deploy_path']

namespace :deploy do
  desc "Symlinks the config.yml"
  task :symlink_app_config do
    on roles(:app) do
      execute "ln -nfs #{deploy_to}/shared/config/config.yml #{release_path}/config/config.yml"
    end
  end

  after :publishing, :symlink_app_config
end
