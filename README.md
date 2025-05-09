## Tasks

### docker-image-build

```bash
export VERSION=`version get`
docker build -t "ghcr.io/a-h/coder-template:$VERSION" .
```

### docker-run

interactive: true

```bash
export VERSION=`version get`
docker run -it --rm ghcr.io/a-h/coder-template:$VERSION
```

### docker-publish

```bash
export VERSION=`version get`
docker push ghcr.io/a-h/coder-template:$VERSION
```

### archive

```bash
git archive --format=tar --output=template.tar HEAD
```
