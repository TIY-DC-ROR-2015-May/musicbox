require 'active_record'
require 'yaml'

if ENV["DATABASE_URL"]
  # We're on Heroku
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

else
  # Do what we've always done
  db_config = YAML::load(File.open('config/database.yml'))

  env_config = if ENV["TEST"]
    db_config["test"]
  else
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    db_config["development"]
  end

  raise "Could not find database config for environment" unless env_config
  ActiveRecord::Base.establish_connection(env_config)
end