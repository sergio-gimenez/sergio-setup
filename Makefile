.PHONY: bootstrap-remote

bootstrap-remote:
	@if [ -z "$(HOST)" ]; then \
		printf 'Usage: make bootstrap-remote HOST=<ssh-host>\n' >&2; \
		exit 1; \
	fi
	./scripts/sync-ssh-to-remote.sh "$(HOST)"
	@if [ -d "$$HOME/.agents" ]; then \
		./scripts/sync-agents-to-remote.sh "$(HOST)"; \
	else \
		printf 'Skipped ~/.agents sync. Source directory missing.\n'; \
	fi
