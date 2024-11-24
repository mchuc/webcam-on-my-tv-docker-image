#!/bin/bash
docker build -t chuc/webcam-on-my-tv-docker-image:apple-silicon --no-cache .
docker push chuc/webcam-on-my-tv-docker-image:apple-silicon