require 'rufus-scheduler'
require './src/awaybot.rb'

$stdout.sync = true

puts 'Starting scheduler...'

scheduler = Rufus::Scheduler.singleton

scheduler.cron '0 9 * * *' do
  AwayBot.run('major')
end

scheduler.join