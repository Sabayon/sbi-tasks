ORG ?= Sabayon
OVERLAY ?= sabayon-distro
CLI ?= mottainai-cli

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

.PHONY: bump-atom
bump-atom:
	# TARGET sys-devel/gcc/gcc-8.2.0-r6.ebuild
	# TARGETVERSION 8.2.0-r6
	# ATOM sys-devel/gcc
	# SOURCE sys-devel/gcc/gcc-7.3.0-r3.ebuild
	$(CLI) task compile bots/ebuild-maint/maint-fork.tmpl \
                            -s OverlayName=$(OVERLAY) \
                            -s UpstreamOrg=$(ORG) \
                            -s SourceEbuild=$(SOURCE) \
                            -s TargetEbuild=$(TARGET) \
                            -s Version=$(TARGETVERSION)  \
                            -s Atom=$(ATOM) \
                            -o ..task.yaml
	$(CLI) task create --yaml ..task.yaml
	rm -rf ..task.yaml
