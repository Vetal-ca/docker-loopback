# Single stage build
FROM alpine:latest
LABEL maintainer="Vitali Khlebko"

# Install runtime dependencies
RUN apk add --no-cache iproute2 jq net-tools coreutils

# Copy the script
ADD ./run.sh /

ENTRYPOINT ["/run.sh"]
