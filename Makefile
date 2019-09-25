ORG ?= Sabayon
OVERLAY ?= sabayon-distro
CLI ?= mottainai-cli

.PHONY: all
all: help

.PHONY: help
help:
	@echo "====================================================================="
	@echo " Sabayon Infra Tasks"
	@echo "====================================================================="
	@echo "docker-mottainai      Create tasks for build Mottainai Docker images."
	@echo "validate              Run replicant validation."
	@echo "deploy                Run replicant ensure."
	@echo "webhooks              Update Mottainai WebHooks."
	@echo "kernel-tracker        Create task for Kernel bumps."
	@echo "tasks                 Create all tasks YAML files (from templates)."
	@echo "mottainai-ebuild-tag  Create Mottainai ebuild tags from develop."
	@echo "bump-atom             Bump atom to our overlay. Default sabayon-distro."
	@echo "tag-server            TBD"
	@echo "repo-remove-pkgs      Create task for remove packages from a specific"
	@echo "                      repository. (Only ARM for now)."
	@echo "repo-create-pkgs      Create task for force compilation of the packages"
	@echo "                      related to a specific stage and repo."
	@echo "                      (Only ARM for now)."

.PHONY: repo-create-pkgs
repo-create-pkgs:
	@make/repo-create-pkgs

.PHONY: repo-remove-pkgs
repo-remove-pkgs:
	@make/repo-remove-pkgs.sh

.PHONY: docker-mottainai
docker-mottainai:
	make/docker-mottainai

.PHONY: validate
validate:
	make/validate

.PHONY: clean-nodes
clean-nodes:
	make/clean-nodes

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

.PHONY: mottainai-ebuild-tag
mottainai-ebuild-tag:
	$(CLI) task create --yaml bots/mottainai/overlay-devel-tag.yaml

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

.PHONY: tag-server
tag-server:
	$(CLI) task compile bots/mottainai/release.tmpl \
                            -s OverlayName=$(OVERLAY) \
                            -s UpstreamOrg=$(ORG) \
                            -s Version=0.1  \
                            -s Component=mottainai-server \
                            -s TargetTag=master \
                            -o ..task.yaml
	$(CLI) task create --yaml ..task.yaml
	rm -rf ..task.yaml
