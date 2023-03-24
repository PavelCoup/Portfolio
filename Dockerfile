FROM golang:1.8 AS wcg
SHELL ["/bin/bash", "-c"]
RUN cd /go \
&& git clone https://github.com/PavelCoup/word-cloud-generator.git \
&& cd /go/word-cloud-generator \
&& go get -u github.com/GeertJohan/go.rice/rice; go get -u github.com/gorilla/mux \
&& make build

FROM alpine:latest
COPY --from=wcg /go/word-cloud-generator/artifacts/linux/word-cloud-generator /
RUN chmod +x /word-cloud-generator
EXPOSE 8888
ENTRYPOINT ["nohup", "/word-cloud-generator"]