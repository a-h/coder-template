## Tasks

### docker-image-build

```bash
export VERSION=`version get`
docker build -t "ghcr.io/a-h/coder-template:$VERSION" ./template
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

### extensions-download

Dir: ./tools

```bash
# Setup
./extension_download.sh mkhl.direnv

# Web
./extension_download.sh dbaeumer.vscode-eslint
./extension_download.sh ecmel.vscode-html-css

# Go
./extension_download.sh golang.Go

# Docker
./extension_download.sh ms-azuretools.vscode-docker

# C#
./extension_download.sh ms-dotnettools.csharp

# Python
./extension_download.sh ms-python.python
./extension_download.sh ms-python.vscode-pylance
./extension_download.sh ms-python.isort

# C / C++
./extension_download.sh ms-vscode.cmake-tools
./extension_download.sh ms-vscode.cpptools
./extension_download.sh ms-vscode.cpptools-extension-pack
./extension_download.sh twxs.cmake

# yaml
./extension_download.sh redhat.vscode-yaml

# Java
./extension_download.sh redhat.java
./extension_download.sh vscjava.vscode-gradle
./extension_download.sh vscjava.vscode-java-debug
./extension_download.sh vscjava.vscode-java-pack
./extension_download.sh vscjava.vscode-maven
```
