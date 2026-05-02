ARG APP_VERSION=2.10.0

FROM python:3.14-slim

ARG APP_VERSION

# libchromaprint-tools provides fpcalc, required by the beets chroma plugin
# for acoustic fingerprinting via the AcoustID service.
# ffmpeg provides ffprobe, required by beets to detect and fix file extensions.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ffmpeg \
        libchromaprint-tools \
    && rm -rf /var/lib/apt/lists/*

# Install beets with optional plugin dependencies:
#   chroma    – acoustic fingerprinting (requires fpcalc + AcoustID API key)
#   fetchart  – downloads album art from the web
#   embedart  – embeds album art into audio files
#   lastgenre – tags genres via MusicBrainz (+ Last.fm if API key is configured)
RUN pip install --no-cache-dir \
    "beets[chroma,fetchart,embedart,lastgenre]==${APP_VERSION}"

RUN groupadd -g 1000 beets \
    && useradd -u 1000 -g beets -s /sbin/nologin -d /home/beets -m beets

USER 1000
WORKDIR /home/beets

ENTRYPOINT ["beet"]
