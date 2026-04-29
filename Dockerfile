FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    bash \
    bc \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://cli.claude.ai/install.sh | sh

WORKDIR /app
COPY . .

RUN chmod +x tests/run-all.sh tests/unit/*/*.sh tests/integration/*.sh

CMD ["bash", "tests/run-all.sh"]
