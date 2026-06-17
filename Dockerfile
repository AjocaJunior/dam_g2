FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN mkdir -p build && dart compile exe bin/api_server.dart -o build/api_server

FROM debian:bookworm-slim

WORKDIR /app

COPY --from=build /app/build/api_server ./api_server

EXPOSE 8080

CMD ["./api_server"]
