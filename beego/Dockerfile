FROM golang:1.13.5

ENV GOPATH $GOPATH:/go
ENV PATH $PATH:$GOPATH/bin
WORKDIR /go/src/app

RUN apt -y update &&\
  go get "github.com/beego/bee" &&\
  go get "github.com/astaxie/beego"
