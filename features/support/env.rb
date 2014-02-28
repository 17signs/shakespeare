ENV['RAILS_ENV'] ||= "test"

require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')

require 'cucumber/formatter/unicode'
require 'cucumber/rails/world'

require 'webrat'
require 'webrat/core/matchers'

class ActiveSupport::TestCase
  setup do |session|
    session.host = "localhost:3001"
  end
end

Webrat.configure do |config|
  config.mode             = :selenium
  config.application_framework = :rack
  config.open_error_files = false
end

World(Rack::Test::Methods)
World(Webrat::Methods)
