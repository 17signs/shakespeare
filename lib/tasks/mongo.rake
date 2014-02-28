# lib/tasks/mongo.rake

namespace :db do
  namespace :test do
    task :prepare => :environment do
      MongoMapper.connect('test')
      MongoMapper.database.collections.select {|c| c.name !~ /system/ }.each(&:drop)
      MongoMapper.connect(Rails.env)
    end
  end
end

task 'test:prepare' => 'db:test:prepare'