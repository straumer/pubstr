SEC := $(shell [ -z "$(MAKECMDGOALS)" ] && [ -f sec.sh ] && ./sec.sh)
GENERAL := $(shell [ -d events ] && find events -name "*.sh" -type f)
LONGFORM := $(shell [ -d events ] && find events -name "*.md" -type f)
EVENTS := $(GENERAL:.sh=.json) $(LONGFORM:.md=.json)
EVENTS_WL := $(shell [ -d events ] && find events -name "*.json" -type f) events/some_necessary.json

ifeq ($(shell ./bin/validate_sec '$(SEC)'),f)
all:
	@echo "sec.sh needs to exist and output a valid hex sec key"
else

.SUFFIXES: .sh .md .json

all: $(EVENTS)

.md.json:
	@echo "$< > $@"
	@./bin/longform $(SEC) $< > $@

.sh.json:
	@echo "$< > $@"
	@./bin/general $(SEC) $< > $@
endif

outbox/pubkey: $(firstword $(EVENTS_WL))
	mkdir -p outbox
	jq -r '.[1].pubkey' $< > $@

outbox/relays: outbox/pubkey outbox/relays_seed
	./bin/outbox $$(cat outbox/pubkey) $$(cat outbox/relays_seed) > $@

publish: outbox/relays
	./bin/publish
