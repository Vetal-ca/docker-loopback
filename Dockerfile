FROM alpine:latest
MAINTAINER Vitali Khlebko
# create loopback interface
ADD ./run.sh /

ENTRYPOINT ["/run.sh"]
