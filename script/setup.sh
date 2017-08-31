echo setup starting.....
#docker-compose rm

echo build docker image
command="rackup config.ru -p 2030 -o '0.0.0.0"

docker build --rm -f Dockerfile  --build-arg APP_DIR=app --build-arg  COMMAND="$command" -t pdf_service .

echo setup complete
