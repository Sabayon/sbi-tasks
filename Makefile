.PHONY: all
all: docker-mottainai

.PHONY: docker-mottainai
docker-mottainai:
	make/docker-mottainai

.PHONY: validate
validate:
	make/validate

.PHONY: deploy
deploy:
	make/deploy

.PHONY: webhooks
webhooks:
	make/webhooks

.PHONY: kernel-tracker
kernel-tracker:
	make/kernel-tracker

.PHONY: tasks
tasks:
	make/tasks
