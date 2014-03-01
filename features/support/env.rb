require 'capybara'
require 'capybara/cucumber'
require 'capybara/webkit'

require_relative '../../lib/server/server'

Capybara.app = Dicot::Server

Capybara.javascript_driver = :webkit
