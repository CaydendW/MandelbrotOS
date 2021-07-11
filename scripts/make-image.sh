#!/bin/sh

path="$(dirname $0)/../"
mkdir tmp

cp $path/build/mandelbrotos.elf ./tmp
cp $path/resources/limine.cfg ./tmp
cp $path/thirdparty/limine/limine.sys ./tmp
cp $path/thirdparty/limine/*.bin ./tmp

xorriso -as mkisofs -b limine-cd.bin -no-emul-boot -boot-load-size $(nproc --all) \
	-boot-info-table --efi-boot limine-eltorito-efi.bin -efi-boot-part --efi-boot-image \
	--protective-msdos-label ./tmp -o $path/mandelbrot.iso

$path/thirdparty/limine/limine-install-linux-x86_64 $path/mandelbrot.iso
rm -rf ./tmp
