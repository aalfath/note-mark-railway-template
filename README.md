[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/note-mark?utm_medium=integration&utm_source=button&utm_campaign=note-mark)

# Note Mark on Railway

One-click [Railway](https://railway.com) template for [Note Mark](https://github.com/enchant97/note-mark), a fast, minimal, web-based Markdown notes app with notebooks, attachments and sharing.

- **Version:** Note Mark 1.1.2, official image `ghcr.io/enchant97/note-mark:1.1.2@sha256:27d13ab1b0cbabaecad3158b4776cf093670dcd3ca0748312d4aa70c56412544`
- **Services:** one, `Note Mark`, with a Railway volume at `/data` (SQLite database plus your notes as Markdown files). Health check: `/api/info`.
- **Memory:** about 55 MB idle, under 75 MB with 200 notes and a 10 MB upload. Fits Railway's Free plan (0.5 GB).

## What this wrapper adds

The upstream image is used as is. The [`Dockerfile`](Dockerfile) adds a static BusyBox (the upstream image is distroless) and [`railway-start.sh`](railway-start.sh), which:

1. listens on Railway's `PORT` and sets `PUBLIC_URL` from the Railway domain;
2. checks `AUTH_TOKEN__SECRET` (base64 of at least 32 bytes; a plain long value is base64-encoded for you) and exits non-zero if it is missing or short;
3. turns public sign-up and anonymous user search **off** (upstream leaves them on);
4. on the first boot only, creates your account from `NOTE_MARK_USERNAME` and the generated `NOTE_MARK_PASSWORD`, before the web server starts;
5. sets the Go heap limit from the service's memory limit, then runs `note-mark serve`. Any failure exits non-zero, so Railway's restart policy restarts it.

## Variables

| Variable | Default | What it is |
|---|---|---|
| `PORT` | `8080` | Port the app listens on (Railway routes the domain to it). |
| `NOTE_MARK_USERNAME` | `admin` | Username of the account created on first boot (3–30 letters or digits). |
| `NOTE_MARK_PASSWORD` | generated | Password of that account. Used only on the first boot. |
| `AUTH_TOKEN__SECRET` | generated | Secret that signs login tokens. Changing it logs everyone out. |

Optional, not in the template: `ENABLE_INTERNAL_SIGNUP=true` to let others register (turn it off again afterwards), `FILE_SIZE_LIMIT` (default `12M`), OIDC single sign-on (`OIDC__*`). See the [upstream configuration docs](https://notemark.docs.enchantedcode.co.uk/docs/setup/configuration/).

## After deploy

Copy `NOTE_MARK_PASSWORD` from the service's Variables tab, open the public URL and sign in as `admin`.

## Updates

The template's service builds from this repo. When a new Note Mark version is merged to `main`, Railway shows everyone who deployed it an "update available" notice, and they choose when to apply it. Every version is listed in [`CHANGELOG.md`](CHANGELOG.md), breaking changes first. Back up the `/data` volume before applying an update.

## Licence

Note Mark is AGPL-3.0, by Leo Spratt. This wrapper only packages the official image.
