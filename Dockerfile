FROM golang:1.25-alpine AS server

WORKDIR /src
COPY docker/static_server.go .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o /static-server ./static_server.go

FROM scratch

COPY --from=server /static-server /static-server
COPY exports/web/ /www/

EXPOSE 80

ENTRYPOINT ["/static-server"]
