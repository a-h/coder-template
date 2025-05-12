#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 publisher.name"
  exit 1
fi

input="$1"
publisher="${input%%.*}"
name="${input#*.}"
url="https://${publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${name}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
dest_dir="vsix"
dest_file="${dest_dir}/${name}.vsix"

mkdir -p "$dest_dir"

echo "Downloading ${input}..."
if ! curl -fL "$url" -o "$dest_file"; then
  echo "Download failed for $input"
  exit 1
fi

echo "Saved to $dest_file"

