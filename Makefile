build:
	docker build -t away-bot .

run:
	docker run --rm -e FEED_URL -e SLACK_HOOK_URL -e NAMES away-bot
