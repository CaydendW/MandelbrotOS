KVM = 0

LD = cross/bin/x86_64-elf-ld
CC = cross/bin/x86_64-elf-gcc
AS = nasm

LIBGCC = cross/lib/gcc/x86_64-elf/9.2.0/libgcc.a
ECHFS_UTILS=echfs/echfs-utils
LIMINE_INSTALL=limine/bin/limine-install

ifeq ($(KVM), 1)
	QEMU = qemu-system-x86_64 -hda $(OS) -serial stdio -enable-kvm -smp 2 -machine q35
else
	QEMU = qemu-system-x86_64 -hda $(OS) -serial stdio -smp 2 -machine q35
endif

OS = mandelbrotos.hdd
KERNEL = mandelbrotos.elf

ASFLAGS = -f elf64

CFLAGS := \
	-mcmodel=kernel \
	-ffreestanding \
	-fno-pie \
	-O2 \
	-s \
	-Isrc/include \
	-Wall \
	-Wextra \
	-lm \
	-std=gnu99 \
	-Isrc/acpi/lai/include \
	-fcommon \
	-Isrc/include

LDFLAGS := \
	-static \
	-no-pie \
	-Tresources/linker.ld \
	-Lcross/lib/gcc/x86_64-elf/9.2.0/\
	-lgcc \
	-nostdlib

CFILES := $(shell find src/ -name '*.c')
ASFILES := $(shell find src/ -name '*.asm')
OFILES := $(CFILES:.c=.o) $(ASFILES:.asm=.o)

ifeq ($(RUN), 1)
all: clean $(OS) qemu
else
all: clean $(OS)
endif

$(OS): $(KERNEL)
	@ echo "[DD] $@"
	@ dd if=/dev/zero of=$@ bs=1M seek=64 count=0
	@ echo "[PARTED] GPT"
	@ parted -s $@ mklabel gpt
	@ echo "[PARTED] Partion"
	@ parted -s $@ mkpart primary 2048s 100%
	@ echo "[ECHFS] Format"
	@ $(ECHFS_UTILS) -g -p0 $@ quick-format 512
	@ echo "[ECHFS] resources/limine.cfg"
	@ $(ECHFS_UTILS) -g -p0 $@ import resources/limine.cfg boot/limine.cfg
	@ echo "[ECHFS] resources/limine.sys"
	@ $(ECHFS_UTILS) -g -p0 $@ import resources/limine.sys boot/limine.sys
	@ echo "[ECHFS] boot/"
	@ $(ECHFS_UTILS) -g -p0 $@ import $< boot/$<
	@ echo "[ECHFS] foo.txt(just for testing)"
	@ $(ECHFS_UTILS) -g -p0 $@ import resources/foo.txt tee/bar/foo.txt
	@ echo "[LIMINE] Install"
	@ $(LIMINE_INSTALL) $@

$(KERNEL): $(OFILES)
	@ echo "[LD] $^"
	@ $(LD) $(LDFLAGS) $^ -o $@

%.o: %.c
	@ echo "[CC] $<"
	@ $(CC) $(CFLAGS) -c $< -o $@

%.o: %.asm
	@ echo "[AS] $<"
	@ $(AS) $(ASFLAGS) $< -o $@

clean:
	@ echo "[CLEAN]"
	@ rm -rf $(OFILES) $(KERNEL) $(OS)

qemu: $(OS)
	@ echo "[QEMU]"
	@ $(QEMU)
