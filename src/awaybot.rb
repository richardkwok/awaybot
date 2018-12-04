require 'rubygems'
require 'bundler/setup'
require 'chronic_duration'
require 'slack-notifier'
require 'open-uri'
require 'icalendar'
require 'yaml'
require 'date'
require 'pp'

module AwayBot
  def AwayBot.run(announcement_type)
    puts 'Running...'
    cfg = YAML.load_file('awaybot.yaml')
    unless cfg.key? "#{announcement_type}_announce"
      puts "#{type} is not a known type of announcement."
      Kernel.exit 1
    end

    today = Date.today
    puts "Running for #{today}"

    ics_raw = URI.parse(ENV['FEED_URL']).read
    ics = Icalendar.parse(ics_raw).first
    msg = ''

    if ENV['DEBUG']
      puts "Team:"
      puts ENV['NAMES'].split(';')
    end

    ics.events.each do |event|
      puts "#{event.summary} (#{event.dtstart} - #{event.dtend})" if ENV['DEBUG']
      # Summary in the form of: "FirstName LastName (Time off - 0.5 days)"
      name = (/[^\(]+/.match event.summary)[0].strip
      unless ENV['NAMES'].split(';').include? name
        puts "#{name} not in team"
        next
      end
      first_name = name
      away_start = event.dtstart - 0
      away_end = event.dtend - 1
      return_day = away_end + 1
      # people don't return on the weekend, bump the return day to monday
      return_day += 1 while return_day.saturday? || return_day.sunday?
      away_range = away_start..away_end
      away_duration = (away_end - away_start).to_i + 1
      # sometimes days shows up as hours, and this breaks partial_day analysis
      if hour_match=(/([0-9\.]+) hour/.match event.summary)
      days = (hour_match[1].to_i / 8.0).to_s + " day"
      event.summary.gsub! hour_match[0], days
      end
      # Can't tell a partial day from the dates, but it is in the summary
      partial_day = (/([0-9\.]+) day/.match event.summary)[1].to_i < 1
      # subtract any weekends from the duration
      away_range.each do |date|
        away_duration -= 1 if date.saturday? || date.sunday?
      end
      look_range =
        today..(today + cfg["#{type}_announce"]['look_forward_days'])
      next if (away_range.to_a & look_range.to_a).empty?
      puts "Message calc..."
      if away_start > today
        if away_duration == 1 and partial_day
          msg += "#{first_name} is off for part of the day on" \
            " #{away_start.strftime('%A, %B %-d')}.\n"
        elsif away_duration == 1
          msg += "#{first_name} is off for the day on" \
            " #{away_start.strftime('%A, %B %-d')}.\n"
        else
          if today.strftime('%A') == away_start.strftime('%A')
            nxt = 'next '
          else
            nxt = ''
          end
          msg += "#{first_name} is off for #{away_duration} days starting" \
            " #{nxt}#{away_start.strftime('%A, %B %-d')} until" \
            " #{away_end.strftime('%A, %B %-d')}.\n"
        end
      else
        if away_end - today > 0
          text_return = ChronicDuration.output(
            (return_day - today) * 60 * 60 * 24, weeks: true, format: :long, units: 2
          )
          msg += "#{first_name} is off today, returning in #{text_return}.\n"
        elsif partial_day
          msg += "#{first_name} is off part of today.\n"
        else
          msg += "#{first_name} is off today.\n"
        end
      end
    end

    if (msg == '')
      msg = "No vacations planned. :briefcase:"
    end

    if !today.saturday? && !today.sunday?
      msg = ":city_sunrise: Good morning! Here's who's off for the next" \
        " #{cfg["#{type}_announce"]['look_forward_days']} days.\n#{msg}"
      puts msg
      slack = Slack::Notifier.new ENV['SLACK_HOOK_URL']
      slack.ping msg
    end
  end
end
