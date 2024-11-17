# Webcam-On-My-TV Docker Image

This Docker image enables you to stream multicast video and serve it via HTTP as HLS. The image uses **FFmpeg** to transcode multicast streams and **NGINX** to serve the HLS stream and an accompanying web interface.

---

## Features

- **Dynamic Multicast Configuration**: Configure the multicast address and port using environment variables.
- **HLS Streaming**: Converts multicast to HTTP Live Streaming (HLS) for browser compatibility.
- **Integrated Web Server**: NGINX serves the HLS stream and an HTML player on port 8080.

---

## Configuration

### Environment Variables

| Variable    | Default Value     | Description                            |
| ----------- | ----------------- | -------------------------------------- |
| `MULTICAST` | `235.206.241.161` | Multicast address of the input stream. |
| `PORT`      | `34048`           | Multicast port for the input stream.   |

### Network

- **Host Networking**: The container uses `--network=host` to properly receive multicast traffic.
- **HTTP Port**: The web interface and HLS files are served on port 80.

---

## Docker Image

You can also pull the pre-built Docker image from Docker Hub:

```bash
docker pull chuc/webcam-on-my-tv-docker-image:latest
```

## Setup and Usage

### 1. Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/mchuc/webcam-on-my-tv-docker-image.git
cd webcam-on-my-tv-docker-image
```

### 2. Build the Docker Image

Build the Docker image locally for linux:

```bash
docker buildx build --platform linux/amd64 -t chuc/webcam-on-my-tv-docker-image:latest --no-cache .
```

### 3. Run the Docker Container

Run the container with your desired multicast settings:

```bash
docker run -d \
 --name webcam_on_my_tv \
 -e MULTICAST="235.206.241.161" \
 -e PORT=34048 \
 -p 8080:8080 \
 --network=host \
 chuc/webcam-on-my-tv-docker-image
```

### 4. Access the Web Interface

Open a browser and navigate to:

```
http://localhost:8080
```

You will see the HTML5 player streaming your multicast input.

Test Your TV in general:

```
http://localhost:8080/test.html
```

---

## Folder Structure

The project structure:

```
.
├── Dockerfile       # Defines the Docker image
├── default_page     # NGINX configuration
├── index.html       # Web interface
├── LICENCE          # license
├── readme.md        # this file
└── start.sh         # Startup script for FFmpeg and NGINX

```

---

## Customization

### Changing Multicast Address and Port

To change the multicast input settings, modify the `MULTICAST` and `PORT` environment variables when running the container:

```bash
docker run -d \
 --name webcam_on_my_tv \
 -e MULTICAST="235.206.241.161" \
 -e PORT=1234 \
 -p 8080:8080 \
 --network=host \
 chuc/webcam-on-my-tv-docker-image
```

### Modifying the Web Interface

The HTML player is stored in `index.html`. You can customize it to fit your requirements.

---

## Troubleshooting

1. **Multicast Traffic Not Received**:

   - Ensure the host system is configured to receive multicast traffic.
   - Use `--network=host` in Docker to allow multicast.

2. **No Video Stream**:

   - Check if the multicast address and port are correct.
   - Inspect FFmpeg logs by running: `docker logs webcam_on_my_tv`.

   ```
    - On Mac/Windows in Docker Desktop
   In Settings > Resources > Networking be sure to check "Enable host networking"
   ```

3. **Firewall Issues**:
   - Ensure the necessary ports are open (multicast port and HTTP port 8080).

---

## License

This project is licensed under the Apache License 2.0.

---

Got feedback or issues? Feel free to open an issue or contribute! 🎉
