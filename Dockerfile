# OmniRoute 3.8.51 for Railway — pinned by digest (linux/amd64 + arm64 manifest)
FROM diegosouzapw/omniroute:3.8.51@sha256:8bd462c9f60d8eda79329cfbb6ea7ea723505fe7721beb944f3d43835409e218

# Railway volumes are mounted root-owned, but OmniRoute runs as the `node`
# user (uid 1000). Start as root, fix ownership of the data volume, then drop
# back to `node` before launching the upstream entrypoint + server.
USER root
COPY --chmod=755 railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh

ENV PORT=20128 \
    HOSTNAME=0.0.0.0 \
    DATA_DIR=/app/data

EXPOSE 20128
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["node", "dev/run-standalone.mjs"]
