FROM golang
WORKDIR /driver/source
WORKDIR /driver/source
ADD . .
ENV DB2HOME=/driver/source/clidriver
ENV CGO_CFLAGS=-I$DB2HOME/include
ENV CGO_LDFLAGS=-L$DB2HOME/lib
ENV LD_LIBRARY_PATH=/driver/source/clidriver/lib
RUN apt-get update && apt-get install -y libxml2-dev