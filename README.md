# Run it on Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

Schedule it to run daily via the [[heroku scheduler]](https://addons.heroku.com/scheduler)

Slack Incoming Webhook setup page - https://freshbooks.slack.com/services/new/incoming-webhook

# Run it locally

```
  export FEED_URL='https://freshbooks.bamboohr.com/feeds/feed.php?id=SNIP'
  export SLACK_HOOK_URL='https://hooks.slack.com/services/T024K32LX/B060UFKPE/SNIP'
  export NAMES='Sen Nordstrom;Jason Shaw;Jonathan Yee'
  ruby awaybot.rb major
```
