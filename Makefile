IMAGE ?= w0rp/ale
DOCKER = docker run -a stderr --rm -v $(PWD):/testplugin -v $(PWD)/test:/home "$(IMAGE)"

test-setup:
	docker images -q $(IMAGE) || docker pull $(IMAGE)

test: test-setup
	vims=$$(docker run --rm $(IMAGE) ls /vim-build/bin | grep -E '^n?vim'); \
	if [ -z "$$vims" ]; then echo "No Vims found!"; exit 1; fi; \
	for vim in $$vims; do \
	  $(DOCKER) $$vim '+Vader! test/*'; \
	done

.PHONY: test-setup test
