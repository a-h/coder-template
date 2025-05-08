## Tasks

### docker-image-build

```bash
nix build .#docker-image
```

### docker-image-load-aarch64-linux

```bash
nix build .#packages.aarch64-linux.docker-image
docker load < result
```

### docker-image-load-x86_64-linux

```bash
nix build .#packages.x86_64-linux.docker-image
docker load < result
```

### docker-run

interactive: true

```bash
docker run -it --rm ghcr.io/a-h/coder-template:latest
```
