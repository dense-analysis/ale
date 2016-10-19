IMAGE ?= w0rp/ale
CURRENT_IMAGE_ID = 107e4efc4267
DOCKER_FLAGS = --rm -v $(PWD):/testplugin -v $(PWD)/test:/home "$(IMAGE)"

test-setup:
	docker images -q w0rp/ale | grep ^$(CURRENT_IMAGE_ID) > /dev/null || \
		docker pull $(IMAGE)

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
		docker run -a stderr $(DOCKER_FLAGS) $$vim '+Vader! test/*' || EXIT=$$?; \
	done; \
	echo; \
	echo '========================================'; \
	echo 'Running Vint to lint our code'; \
	echo '========================================'; \
	echo 'Vint warnings/errors follow:'; \
	echo; \
	docker run -a stdout $(DOCKER_FLAGS) vint -s /testplugin | sed s:^/testplugin/:: || EXIT=$$?; \
	echo; \
	echo; \
	exit $$EXIT;

.DEFAULT_GOAL := test
