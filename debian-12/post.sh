#!/usr/bin/env sh

cd output-pirogue-os/
output_file="PiRogue-OS-12-${image_flavor}-$(date '+%Y-%m-%d').img"
output_archive="${output_file}.xz"
output_checksum="${output_archive}.sha256"

mv image $output_file
echo "Compressing the image"
pixz $output_file $output_archive
sha256sum $output_archive > $output_checksum
