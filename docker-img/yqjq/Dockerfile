FROM alpine:latest

RUN apk update && \
    apk add \
    yq \
    jq

#CMD ["yq"]
ENTRYPOINT ["yq"]
