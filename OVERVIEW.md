# Deploy and Host Note Mark on Railway

Note Mark is a fast, minimal, web-based Markdown notes app. Notes live in notebooks as plain Markdown files on disk, with GitHub-flavoured Markdown, a quick editor with shortcuts, rendered and plain views, file attachments, dark and light themes, per-note sharing with other users or the public, and optional OIDC single sign-on.

## About Hosting Note Mark

Note Mark is one Go binary that serves both the API and the web app. It keeps users and a tree cache in SQLite and every note as a normal Markdown file, all under one data folder, so hosting it means one service and one volume. It needs a base64 token secret of at least 32 bytes, its public URL for CORS and cookies, and an account to log in with. Upstream leaves public sign-up open, so a public deploy needs it closed. This template generates the secrets, derives the URL from the Railway domain, creates your account on first boot and turns public sign-up off.

## Common Use Cases

* A private Markdown notebook or journal you can reach from any browser or phone
* A small team wiki where each person keeps notebooks and shares chosen notes
* Publishing a few notes publicly while keeping the rest private

## Dependencies for Note Mark Hosting

* One Railway service built from [aalfath/note-mark-railway-template](https://github.com/aalfath/note-mark-railway-template)
* One Railway volume at `/data` (SQLite database and Markdown files)

### Deployment Dependencies

* [Note Mark](https://github.com/enchant97/note-mark), release [v1.1.2](https://github.com/enchant97/note-mark/releases/tag/v1.1.2)
* Official image `ghcr.io/enchant97/note-mark:1.1.2`, pinned by digest
* [Note Mark documentation](https://notemark.docs.enchantedcode.co.uk/)

### Implementation Details

**What you get:** one service, `Note Mark`, on a public Railway domain with a health check on `/api/info`, and a volume at `/data`. There is no database service: Note Mark stores everything in SQLite and files on the volume.

**After deploy:** open the service's Variables tab, copy `NOTE_MARK_PASSWORD`, open the public URL and sign in as `admin` (or your `NOTE_MARK_USERNAME`). Change the password in your profile if you like; the variable is only used on the first boot.

**More users:** public sign-up is off. To let people register, set `ENABLE_INTERNAL_SIGNUP=true`, redeploy, and set it back to `false` once they have signed up. Optional settings such as OIDC (`OIDC__ISSUER_URL`, `OIDC__CLIENT_ID` and friends) and `FILE_SIZE_LIMIT` (default 12M) are in the upstream configuration docs.

**Resources:** idle use is about 55 MB of RAM; 200 notes and a 10 MB upload stayed under 75 MB, so it runs on the Free plan's 0.5 GB.

**Updates:** the service builds from our GitHub repo, so Railway shows an update notice when we publish a new Note Mark version. Read the repo's `CHANGELOG.md` before you apply one. Back up the volume first (Railway volume backups, or copy `/data`).

## Why Deploy Note Mark on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Note Mark on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
