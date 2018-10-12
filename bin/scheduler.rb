require 'rufus-scheduler'
require './src/awaybot.rb'

puts 'Starting scheduler...'

scheduler = Rufus::Scheduler.new

scheduler.every '1s' do
  AwayBot.test()
end

scheduler.join