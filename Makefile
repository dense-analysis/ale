IMAGE ?= w0rp/ale
DOCKER = docker run -a stderr --rm -v $(PWD):/testplugin -v $(PWD)/test:/home -v ${PWD}:/home/ale "$(IMAGE)"

test-setup:
	docker images -q $(IMAGE) || docker pull $(IMAGE)

test: test-setup
	vims=$$(docker run --rm $(IMAGE) ls /vim-build/bin | grep -E '^n?vim'); \
	if [ -z "$$vims" ]; then echo "No Vims found!"; exit 1; fi; \
	EXIT=0; \
	for vim in $$vims; do \
	  $(DOCKER) $$vim '+Vader! test/*' || EXIT=$$?; \
	done; \
	$(DOCKER) vint -s /testplugin || EXIT=$$?; \
	exit $$EXIT;

.PHONY: test-setup test
