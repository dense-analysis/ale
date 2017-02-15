SHELL := /usr/bin/env bash
IMAGE ?= w0rp/ale
CURRENT_IMAGE_ID = 107e4efc4267
DOCKER_FLAGS = --rm -v $(PWD):/testplugin -v $(PWD)/test:/home "$(IMAGE)"
tests = test/*

test-setup:
	docker images -q w0rp/ale | grep ^$(CURRENT_IMAGE_ID) > /dev/null || \
		docker pull $(IMAGE)

vader: test-setup
	@:; \
	vims=$$(docker run --rm $(IMAGE) ls /vim-build/bin | grep -E '^n?vim'); \
	if [ -z "$$vims" ]; then echo "No Vims found!"; exit 1; fi; \
	for vim in $$vims; do \
		docker run -a stderr $(DOCKER_FLAGS) $$vim '+Vader! $(tests)'; \
	done

test: test-setup
	@:; \
	vims=$$(docker run --rm $(IMAGE) ls /vim-build/bin | grep -E '^n?vim'); \
	if [ -z "$$vims" ]; then echo "No Vims found!"; exit 1; fi; \
	EXIT=0; \
	for vim in $$vims; do \
		echo; \
		echo '========================================'; \
		echo "Running tests for $$vim"; \
		echo '========================================'; \
		echo; \
		docker run -a stderr $(DOCKER_FLAGS) $$vim '+Vader! $(tests)' || EXIT=$$?; \
	done; \
	echo; \
	echo '========================================'; \
	echo 'Running Vint to lint our code'; \
	echo '========================================'; \
	echo 'Vint warnings/errors follow:'; \
	echo; \
	set -o pipefail; \
	docker run -a stdout $(DOCKER_FLAGS) vint -s /testplugin | sed s:^/testplugin/:: || EXIT=$$?; \
	set +o pipefail; \
	echo; \
	echo '========================================'; \
	echo 'Running custom checks'; \
	echo '========================================'; \
	echo 'Custom warnings/errors follow:'; \
	echo; \
	set -o pipefail; \
	docker run -a stdout $(DOCKER_FLAGS) /testplugin/custom-checks /testplugin | sed s:^/testplugin/:: || EXIT=$$?; \
	set +o pipefail; \
	echo; \
	exit $$EXIT;

.DEFAULT_GOAL := test
