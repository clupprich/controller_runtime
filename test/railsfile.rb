require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails", ENV.fetch("RAILS_VERSION", "~> 7.1")
  gem "controller_runtime", path: "../"
end

require "rails"
require "action_controller/railtie"

logger = ActiveSupport::Logger.new($stdout)
logger.level = 3
Rails.logger = logger

class TestApp < Rails::Application
  # secrets.secret_token    = "secret_token"
  # secrets.secret_key_base = "secret_key_base"

  config.hosts << "example.org"

  routes.draw do
    resources :books, only: :index
  end
end

class BooksController < ActionController::Base
  include Rails.application.routes.url_helpers

  def index
    ActiveSupport::Notifications.instrument("process.example") do
      sleep 0.1
    end

    render inline: "books#index"
  end
end

ControllerRuntime.register :example, label: "Example", event: "process.example"

# require "rails/command"
# require "rails/commands/server/server_command"

# options = {
#   app: TestApp,
#   Host: '0.0.0.0'
# }
# Rails::Server.new(options).start
