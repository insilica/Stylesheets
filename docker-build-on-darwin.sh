#!/usr/bin/env bash

clj -T:build uberjar

# Spin up a linux/amd64 image to build a docker
# image of the same architecture. The resulting
# image is saved to ./result

docker run --rm -it \
    --platform linux/amd64 \
    -v .:/opts/Stylesheets \
    nixos/nix:latest bash -c "
mkdir -p ~/.config/nix
echo '
experimental-features = nix-command flakes
filter-syscalls = false
' > ~/.config/nix/nix.conf
cd /opts/Stylesheets
nix build .#image.x86_64-linux
cp --remove-destination \"$(readlink result)\" result
exec bash
"
