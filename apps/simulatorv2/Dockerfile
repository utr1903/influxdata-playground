# syntax=docker/dockerfile:1

### Build
FROM golang:1.20-buster AS build

WORKDIR /app

COPY . .

RUN go mod download

RUN go build -o ./out .

### Deploy
FROM gcr.io/distroless/base-debian10

ARG APP_NAME

WORKDIR /

COPY --from=build /app/out /out

EXPOSE 8080

USER nonroot:nonroot

CMD ["./out"]