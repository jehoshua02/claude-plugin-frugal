FROM alpine:3.21

RUN apk add --no-cache bash bc curl jq

RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app
COPY . .

RUN chmod +x tests/run-all.sh tests/unit/*/*.sh tests/integration/*.sh

CMD ["bash", "tests/run-all.sh"]
