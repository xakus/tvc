sudo docker run -it \
  --platform linux/arm64 \
  -v "$PWD":/app \
  ghcr.io/cirruslabs/flutter:latest \
  bash -c "apt-get update && \
           apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev && \
           cd /app && flutter build linux"
