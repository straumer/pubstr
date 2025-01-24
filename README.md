# Pubstr

Pubstr (Publish Stuff Through Relays) is a combination of shell scripts and a makefile to generate and publish nostr events under an existing hex-encoded private key.

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

A new one can also be obtained from the first line of `nostril --content ""`, but most people will want to obtain the `nsec` from some nostr app or keystore since pubstr is only for publishing, not for viewing events. 

Next create an executable `sec.sh` script in the repository root and make it output the obtained hex sec key when run. A password manager like [pass](https://www.passwordstore.org/) can be used to avoid storing the key in plaintext. An example script with `pass` could look like:

```
#!/bin/sh

pass show nostr/test
```

### Generate events

To generate the events from files in the `events` directory, simply run `make` and the events will appear in `.json` suffixed files. The file's format and type of event that is generated depends on the file suffix as follows.

#### General events

Executable files with the `.sh` suffix take a hex sec key as an argument and write the desired enveloped event to standard output when run. A simple example:

```
#!/bin/sh

nostril --sec "$1"\
    --envelope\
    --content "hello there"
```

#### Long-form events

Files suffixed with `.md` are markdown formatted long-form content. They also set some variables via shell code before the `^^^` marker that will be evaluated. For example:

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

An article in multiple languages can be made in a directory that contains an `eval` file. The `eval` file is evaluated and sets common variables among each language version. Each language version is named `<lang>.md` within the same directory with `<lang>` being an `ISO-639-1` language, for example `en.md`, `es.md` etc. The `ID` variable needs to be set explicitly in each of those language files and the directory name should be unique since it is used for the `lg` tag of the generated events to form a link between the events that could be used for grouping purposes in apps, but isn't yet.

### Publish events

Add a seed websocket relay url in the `outbox/relays_seed` file. It should be a nostr relay where the follow list of your account is located, for example `wss://nos.lol`. Other write/outbox relays are derived from it via the "gossip model" (for now) and then listed in the `outbox/relays` file. To publish the events, simply run:

```
make publish
```

It only publishes a given event if either the event changed or there is a new relay to which the event hasn't been published.

If your write/outbox relays change, just modify `outbox/relays` and `outbox/relays_seed` as needed and run `make publish` again. The same event will only be sent one time to a relay and never again as long as the `outbox/replies` directory, which contains replies for each relay domain, is left untouched.
