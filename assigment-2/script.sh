#!/bin/bash
PORT=8080
APP=golang_app

function cleanup {
  echo "Stopping and removing container"
  docker stop $APP
  docker rm -f $APP
  docker rmi -f $APP
}

function healthcheck {
    echo "Checking if container is running..."
    STATUS=`docker ps -f "name=$APP" --format "{{.State}}"` 
    if [ -z "$STATUS" ]; then
        echo "Container is not running."
    else
	LISTENER=$(docker port $APP)
        echo "STATUS: $STATUS listening on :$LISTENER"
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --port)
            shift
            if [[ $# -gt 0 ]]; then
                PORT="$1"
                if [[ $PORT =~ ^[0-9]+$ ]]; then
                    echo "Using provided PORT: $PORT"
                    shift
                fi
            else
                echo "Error: Port number not provided. Application will listen on $PORT"
            fi
            ;;
            --healthcheck)
              healthcheck
              exit 1
            ;;
            
        *)
            echo "Error: Unknown option $1"
            exit 2
            ;;
    esac
done

cat <<EOF > Dockerfile
FROM golang:latest
WORKDIR /app
COPY go.mod main.go .
RUN go build -o /app/app
EXPOSE $PORT
CMD ["sh", "-c", "BIND_ADDRESS=:$PORT ./app"]
RUN rm -rf /bin/bash
EOF

docker build -t $APP .
docker run -it --name $APP -p $PORT:$PORT $APP

trap cleanup SIGINT
trap cleanup EXIT
