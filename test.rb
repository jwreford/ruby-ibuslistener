require_relative 'bmw-ibus/ibuscontroller'
#require_relative 'bmw-ibus/lib/bmw/ibus'
gem 'sidekiq'
gem 'sinatra'

#redisInstance = system( "redis-server &" )
listener = IBusController.new
listener.listen
