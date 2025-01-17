# Pubstr

Pubstr (Publish Stuff Through Relays) is a combination of shell scripts and a makefile to generate and publish nostr events under an existing hex-encoded private key.

So far it only supports long-form articles (kind `30023`).

## Requirements

It should be mostly POSIX compliant except for these CLI tools:

- GNU Make
- nostril
- jq
- websocat

To convert a nostr `nsec` key to its needed hex-encoded private key you can use something like:

- key-convertr

## Usage

### Get hex sec key

First we need a hex sec key which can be obtained from an existing `nsec` key for example like so:

```
key-convertr --to-hex <nsec key>
```

A new one can also be obtained from the first line of `nostril --content ""`, but most people will want to obtain the `nsec` from some nostr app or keystore since pubstr is only for publishing, not making and viewing comments and so on. 

### Generate events

Markdown articles suffixed with `.md` can be made anywhere in the `articles` directory. They also set some variables via shell code before the `^^^` marker that is later evaluated. For example:

```
PUBLISHED=$(date -d 2024-04-08 +%s)
CREATED=$(date -d 2024-04-24 +%s)
TITLE="My Great Article"
SUMMARY="This is some summary."
^^^
Lam odit recusandae voluptas et aliquam sit illo. Aliquam itaque quaerat fuga. Ratione dignissimos quo aut ut debitis. Eius porro sed explicabo. Fuga dolor hic nostrum quia et veniam. Neque dolorum rerum ea.

# Section

Qui dolores maxime nobis. Et consectetur nihil assumenda et veniam nulla. Facilis excepturi quia minima nisi enim dolorum.
```

The `d` identifier tag is by default the file name minus the `.md` suffix, but can be set via the `ID` variable above `^^^`.

An article in multiple languages can be made in a directory that contains an `eval` file. The `eval` file is evaluated and sets common variables among each language version. Each language version is named `<lang>.md` within the same directory with `<lang>` being an `ISO-639-1` language, for example `en.md`, `es.md` etc. The `ID` variable needs to be set explicitly in each of those language files and the directory name should be unique since it is used for the `lg` tag of the generated events to form a link between the articles that could be used for grouping purposes in apps, but isn't yet.

To generate the events run:

```
make sec=<hex sec key>
```

### Publish events

A seed websocket url is needed to fetch the follow list of an account from which other write/outbox websocket urls are derived via the "gossip model" (for now) and then listed in the `outbox` file. The generated events are then sent to those websocket urls. To publish for the first time, specify the seed url where the follow list is to be found (example: `wss://nos.lol`) like so:

```
make publish outbox_seed=<websocket url>
```

Publishing after that is simpler since the write/outbox urls now exist:

```
make publish
```

It only publishes a given event if either the event changed or there is a new relay to which the event hasn't been published.

If your write/outbox relays change, just modify `outbox` and `outbox_seed` or delete them and run `make publish` with the `outbox_seed` parameter again. The same event will only be sent one time to a relay and never again as long as the `public` directory, which contains replies for each relay domain, is left untouched.
