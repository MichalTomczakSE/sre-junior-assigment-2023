FROM golang:latest
WORKDIR /app
COPY go.mod main.go ./
RUN go build -o /app/app
EXPOSE 8080
CMD ["/app/app"]
RUN rm -rf /bin/bash