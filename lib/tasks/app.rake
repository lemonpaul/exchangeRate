namespace :app do
  desc 'Clear all data of application'
  task clean: :environment do
    Rake::Task["db:drop"].execute
    Rake::Task["db:create"].execute
    Rake::Task["db:migrate"].execute
    Rake::Task["log:clear"].execute
    Rake::Task["tmp:clear"].execute
    Rake::Task["jobs:clear"].execute
    Rake::Task["assets:clean"].execute
    Rails.cache.clear
  end

end
