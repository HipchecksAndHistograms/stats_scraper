role :app, "#{StatsScraper.config['deploy_user']}@#{StatsScraper.config['deploy_host']}"

server StatsScraper.config['deploy_host'], user: StatsScraper.config['deploy_user'], roles: %w{app}
