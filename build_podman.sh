#!/bin/bash
set -e

mkdir -p ./release

platforms=(linux/amd64 linux/386 linux/arm64 linux/arm/v7)

build_platform() {
    podman build \
        --platform "$1" \
        --target export \
        --output "type=local,dest=./release" \
        .
}
export -f build_platform

if command -v parallel &>/dev/null; then
    parallel --tag --line-buffer --halt now,fail=1 build_platform ::: "${platforms[@]}"
else
    echo "WARNING: GNU parallel not found, building sequentially" >&2
    for platform in "${platforms[@]}"; do
        build_platform "$platform"
    done
fi

echo "Built binaries:"
ls -la ./release/
