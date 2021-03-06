Sidekiq.average_scheduled_poll_interval = 1
Sidekiq.configure_server do
  schedule_file = 'config/schedule.yml'
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

if Rails.env.production?
  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDIS_URL'] }
  end
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDIS_URL'] }
    Rails.application.config.after_initialize do
      Rails.logger.info("DB Connection Pool size for Sidekiq Server before
                         disconnect is: #{ActiveRecord::Base.connection.pool
                                          .instance_variable_get('@size')}")
      ActiveRecord::Base.connection_pool.disconnect!
      ActiveSupport.on_load(:active_record) do
        config = Rails.application.config.database_configuration[Rails.env]
        config['reaping_frequency'] = ENV['DATABASE_REAP_FREQ'] || 10 # seconds
        # config['pool'] = ENV['WORKER_DB_POOL_SIZE'] ||
        #                  Sidekiq.options[:concurrency]
        config['pool'] = 16
        ActiveRecord::Base.establish_connection(config)
        Rails.logger.info("DB Connection Pool size for Sidekiq Server is now:
                          #{ActiveRecord::Base.connection.pool
                            .instance_variable_get('@size')}")
      end
    end
  end
end
