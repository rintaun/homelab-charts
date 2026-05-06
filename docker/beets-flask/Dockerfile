ARG APP_VERSION=stable
ARG BEETS_VERSION=""

# Runtime image used by all chart components. Commands are supplied by the
# Helm templates per workload (web, workers, db init), so no custom entrypoint
# targets are required in this Dockerfile.
FROM pspitzner/beets-flask:${APP_VERSION}

ARG BEETS_VERSION

# redis-tools provides redis-cli for db-init readiness checks.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        redis-tools \
        libchromaprint-tools \
    && rm -rf /var/lib/apt/lists/*

# Optionally override the beets version bundled by the upstream image. This is
# done at build time to avoid mixed runtime environments from ad hoc PYTHONPATH
# injection.
RUN if [ -n "$BEETS_VERSION" ]; then \
      pip install --no-cache-dir --upgrade "beets==${BEETS_VERSION}"; \
    fi

LABEL description="beets-flask runtime image for Kubernetes workloads"
