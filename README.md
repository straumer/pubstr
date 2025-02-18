# pubstr

pubstr (publish stuff to relays) makes it easy to create, manage and publish arbitrary Nostr events for a given Nostr account, the unix way.

## Requirements

It should be POSIX compliant aside for these required tools:

- curl
- jq
- [nostril](https://github.com/jb55/nostril)
- websocat

Optional, but complementary tools:

- [key-convertr](https://github.com/rot13maxi/key-convertr) to conveniently convert a Nostr `nsec` key to its needed hex-encoded private key.
- [pass](https://www.passwordstore.org/) to keep the private key encrypted at rest.

## Installation

Run, probably with sudo:
```
make install
```
## Quickstart

Assuming you have an `nsec` key for your Nostr account and want to use `pass` to keep it encrypted at rest. Run:
```
key-convertr --to-hex <your-nsec>
pass insert nostr/yourkey # Paste the resulting key at the prompt
```

Then change to a directory where you'll keep your Nostr events and media files. Initialize pubstr here for your Nostr account with default outbox relays and media servers of your liking:
```
pubstr init 'pass show nostr/yourkey' wss://nostr.oxtr.dev wss://nos.lol https://nostrcheck.me
```

Now everywhere in this directory and subdirectories, pubstr will use the initialized Nostr account, similar to `git`. Organize your subdirectories and files here however you like. Let's make the first Nostr note:
```
mkdir -p events/notes
cd events/notes
```

Write a new Nostr note file `hello_world.sh`:
```
#!/bin/sh

nostril --sec "$1"\
        --envelope\
        --content "hello world"
```

Then make it executable and create and publish it to your relays:
```
chmod +x hello_world.sh
pubstr event hello_world.sh | pubstr publish
```

The Nostr EVENT message that was sent to the relays is stored in `hello_world.json`.

For more documentation, check out `pubstr help` and `man pubstr`.
