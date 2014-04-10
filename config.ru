#!/usr/bin/env ruby
require 'rubygems'
require 'bundler'
Bundler.require

ROOT_PATH = File.expand_path(File.dirname(__FILE__))

if ENV['DEBUG'] == 'yes'
  ENV['APP_TYPE'] = 'rhosync'
  ENV['ROOT_PATH'] = ROOT_PATH
  require 'debugger'
end

require 'rhoconnect/server'
require 'rhoconnect/web-console/server'
require 'resque/server'

# Rhoconnect server flags
#Rhoconnect::Server.enable  :stats
Rhoconnect::Server.disable :run
Rhoconnect::Server.disable :clean_trace
Rhoconnect::Server.enable  :raise_errors
Rhoconnect::Server.set     :secret,      'b1886c017947e0e9dc551d3bce5e1e251adf033b9bba52ab41b476cdc571922e29979416cf1328227bfec76ae20becad667d38b8f7a0cb0ffa5c1ad2395a5f89'
Rhoconnect::Server.set     :root,        ROOT_PATH
Rhoconnect::Server.use     Rack::Static, :urls => ['/data'], :root => Rhoconnect::Server.root
# disable Async mode if Debugger is used
if ENV['DEBUG'] == 'yes'
  Rhoconnect::Server.set :use_async_model, false
end

# Load our rhoconnect application
require './application'

# Setup the url map
run Rack::URLMap.new \
	'/'         => Rhoconnect::Server.new,
	'/resque'   => Resque::Server.new, # If you don't want resque frontend, disable it here
	'/console'  => RhoconnectConsole::Server.new # If you don't want rhoconnect frontend, disable it here