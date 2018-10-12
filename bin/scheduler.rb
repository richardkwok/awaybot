require 'rufus-scheduler'
require './src/awaybot.rb'

$stdout.sync = true

puts 'Starting scheduler...'

scheduler = Rufus::Scheduler.singleton

scheduler.every '1s' do
  AwayBot.test()
end


scheduler.join