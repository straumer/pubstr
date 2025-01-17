POSTS := $(shell [ -d articles ] && find articles -name "*.md" -type f)

.SUFFIXES: .md .json

all: $(POSTS:.md=.json) pubkey

.md.json:
	./bin/longform $(sec) $< > $@

pubkey:
	nostril --sec $(sec) | jq -r '.pubkey' > $@

outbox_seed:
	echo $(outbox_seed) > $@	

outbox: pubkey outbox_seed
	./bin/outbox $$(cat pubkey) $$(cat outbox_seed) > $@

publish: outbox
	./bin/publish
