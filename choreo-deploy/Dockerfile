# syntax=docker/dockerfile:1
# Choreo-compatible Dockerfile for Open WebUI
# Uses the official pre-built image from ghcr.io to avoid long build times.
# Only adds a non-root user with UID 10001 to satisfy Choreo's CKV_CHOREO_1 requirement.

FROM ghcr.io/open-webui/open-webui:main

USER root

# Create Choreo-compliant non-root user (UID must be 10000-20000)
RUN groupadd --gid 10001 openwebui 2>/dev/null || true && \
    useradd --uid 10001 --gid 10001 --home /home/openwebui --create-home openwebui 2>/dev/null || true && \
    # mkdir -p /home/openwebui/data && chown -R 10001:10001 /openwebui /home/openwebui

# Copy our patched start script so runtime picks up DATA_DIR defaults and debug logs
COPY start.sh /opt/start.sh
RUN chown 10001:10001 /opt/start.sh && chmod 0755 /opt/start.sh

# open_webui is NOT pip-installed — it's source at /openwebui/backend/open_webui/.
# DATA_DIR is redirected to /home/openwebui/data so UID 10001 can write to it even when
# Choreo mounts a PVC at /openwebui/backend/data (PVC mounts override build-time chown).
WORKDIR /home/openwebui

ENV HOME=/home/openwebui
ENV DATA_DIR=/openwebui 

EXPOSE 8080

# Choreo-compliant: literal numeric UID required by CKV_CHOREO_1 (range 10000-20000)
USER 10001

CMD ["bash", "/opt/start.sh"]
