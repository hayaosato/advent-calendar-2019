FROM golang:1.13.5

ENV GOPATH $GOPATH:/go
ENV PATH $PATH:$GOPATH/bin
WORKDIR /go/src
# COPY . /go/src/app

RUN apt update &&\
  go get "github.com/go-sql-driver/mysql" &&\
  go get "github.com/beego/bee" &&\
  go get "github.com/astaxie/beego"

RUN bee new app
WORKDIR /go/src/app
CMD ["bee", "run"]
