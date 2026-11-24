# Note Mark on Railway: the official all-in-one image, pinned by version and digest,
# plus a static BusyBox (the upstream image is distroless) for the start script and `railway ssh`.
FROM busybox:1.37.0-musl@sha256:f6a95d611e0a8780fabdb2aec43e31275b2720dfefa3e41b16835bfc42454478 AS busybox

FROM ghcr.io/enchant97/note-mark:1.1.2@sha256:27d13ab1b0cbabaecad3158b4776cf093670dcd3ca0748312d4aa70c56412544

COPY --from=busybox /bin/busybox /bin/busybox
RUN ["/bin/busybox", "sh", "-c", "/bin/busybox mkdir -p /usr/bin /bin && /bin/busybox --install -s /bin"]

COPY railway-start.sh /railway-start.sh

# Upstream defaults, set explicitly (the start script derives the rest).
ENV BIND__HOST=0.0.0.0 \
    DATA_PATH=/data \
    STATIC_PATH=/static

EXPOSE 8080
ENTRYPOINT ["/bin/sh", "/railway-start.sh"]
