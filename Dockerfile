FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive

# 直接写 sources.list（https）+ 多次重试
RUN set -eux; \
    printf "deb https://deb.debian.org/debian bookworm main\n\
deb https://deb.debian.org/debian bookworm-updates main\n\
deb https://security.debian.org/debian-security bookworm-security main\n" \
    > /etc/apt/sources.list; \
    apt-get -o Acquire::Retries=5 update; \
    apt-get install -y --no-install-recommends \
      build-essential git curl ca-certificates pkg-config libffi-dev libssl-dev \
      && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app
RUN pip install --upgrade pip && pip install -e . \
 && pip install "uvloop==0.21.*"
RUN mkdir -p /app/trades /app/logs
ENV BOT_CONFIG=bots/example.yaml
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD python -c "import sys; sys.exit(0)"
CMD [ "sh", "-c", "pump_bot -c ${BOT_CONFIG}" ]
