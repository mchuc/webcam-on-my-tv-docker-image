#!/bin/bash
docker buildx build --platform linux/amd64 -t chuc/webcam-on-my-tv-docker-image:latest --no-cache .
docker push chuc/webcam-on-my-tv-docker-image:latest                                               