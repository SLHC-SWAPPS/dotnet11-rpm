FROM mcr.microsoft.com/dotnet/runtime:11.0-preview

# Setup our entrypoint
ENV BIN_DIR=/usr/local/bin/ DOCKERIZE_VERSION=v0.6.1 DOCKERIZE=false
ENV APM_NAME="unknown" APM_URL="http://apm:8585"
COPY docker-entrypoint.sh $BIN_DIR
COPY load-certificates.sh $BIN_DIR
RUN chmod a+x $BIN_DIR/docker-entrypoint.sh
RUN chmod a+x $BIN_DIR/load-certificates.sh
RUN apt-get update
RUN apt-get install -y jq wget tar gzip curl
RUN wget https://nexus.swisslog.net/repository/files/dockerize/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
RUN tar -C $BIN_DIR -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
RUN rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
RUN chown root:root $BIN_DIR/dockerize
ENTRYPOINT ["docker-entrypoint.sh"]
