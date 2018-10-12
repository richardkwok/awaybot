require 'rufus-scheduler'
require_relative '../src/awaybot.rb'

scheduler = Rufus::Scheduler.new

scheduler.every '1s' do
  AwayBot.test()
end

scheduler.join