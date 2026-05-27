FROM registry.ic-ops.net/base/docker:23-dind

ARG GOOS=linux
ARG GOARCH=amd64
ARG VAULT_VERS=1.12.1
ARG GO_VERS=latest
ARG GO_TARGET_DIR=/usr/local/share
ARG JQ_VERS=latest
ARG YQ_VERS=latest

ENV ENV="/root/.profile"

RUN curl -L "https://github.com/mikefarah/yq/releases/${YQ_VERS}/download/yq_linux_amd64" -o "/usr/local/bin/yq" \
    && chmod +x /usr/local/bin/yq
RUN curl -L "https://github.com/jqlang/jq/releases/${JQ_VERS}/download/jq-linux-amd64" -o "/usr/local/bin/jq" \
    && chmod +x /usr/local/bin/jq
RUN curl -L "https://releases.hashicorp.com/vault/${VAULT_VERS}/vault_${VAULT_VERS}_linux_amd64.zip" -o /tmp/vault_${VAULT_VERS}_linux_amd64.zip \
    && unzip /tmp/vault_${VAULT_VERS}_linux_amd64.zip \
    && mv vault /usr/local/bin/vault \
    && rm /tmp/vault_${VAULT_VERS}_linux_amd64.zip

COPY install-go /tmp/install-go
RUN chmod +x /tmp/install-go \
    && sh /tmp/install-go \
    && rm /tmp/install-go

ENV PATH="/usr/local/bin/:$GO_TARGET_DIR/go/bin:$PATH"
ENV GOPATH="$GO_TARGET_DIR/go"
ENV GOBIN="$GO_TARGET_DIR/go/bin"

