ARCH=i386
CROSS=cross
LLVM?=0
RUNONDONE?=1
GRUB?=0

ifeq ($(GRUB), 1)
	GRUB_MKRESCUE=grub2-mkrescue
else
	GRUB_MKRESCUE=grub-mkrescue
endif

ifeq ($(LLVM), 1)
	CC=clang
	LD=ld.lld
	CFLAGS=--target=i686-elf -mno-sse
else
	CC=$(CROSS)/bin/$(ARCH)-elf-gcc
	LD=$(CROSS)/bin/$(ARCH)-elf-ld
	CFLAGS=-nostartfiles
endif

QWERTZ?=0
ifeq ($(QWERTZ), 1)
	CFLAGS+=-DQWERTZ
endif
AZERTY?=0
ifeq ($(AZERTY), 1)
	CFLAGS+=-DAZERTY
endif

LIBGCC=$(CROSS)/lib/gcc/$(ARCH)-elf/$(GCC_VERSION)/libgcc.a

AS=nasm
CWARNINGS=-Wall -Wextra

GCC_VERSION=10.2.0


CFLAGS+=-m32 -std=c99 -nostdlib -nodefaultlibs -ffreestanding -fno-builtin -fno-omit-frame-pointer $(CWARNINGS) $(CINCLUDES) -Isrc/include/
DFLAGS=-g -DDEBUG -O0

ASFLAGS=-f elf

LDFLAGS=-melf_i386 -nostdlib -T src/arch/$(ARCH)/linker.ld -Map=build/mandelbrotos.map 

CSOURCES:=\
$(wildcard src/kernel/*.c)\
$(wildcard src/drivers/*.c)\
$(wildcard src/arch/$(ARCH)/*.c)\
src/string/string.c

ASOURCES:=\
src/arch/$(ARCH)/boot.S\

NASMSOURCES:=\
src/arch/$(ARCH)/interrupts.asm\

COBJECTS:=$(CSOURCES:%.c=%.o)
AOBJECTS:=$(ASOURCES:%.S=%.ao)
NASMOBJECTS:=$(NASMSOURCES:%.asm=%.aso)

OBJS=\
$(ARCH_OBJS)\
$(KERNEL_OBJS)\

KERNEL=build/mandelbrotos.elf

STAGE2=build/stage2_eltorito
GENISOIMAGE=genisoimage

ISO=build/mandelbrotos.iso
DRIVE=myimage.raw
#QEMU=qemu-system-x86_64 -cdrom $(ISO) -serial stdio
QEMU=qemu-system-x86_64 -hda $(DRIVE) --cdrom $(ISO) -serial stdio

.PHONY: all build clean qemu

all: $(ISO)

$(ISO): $(KERNEL)
	mkdir -p iso/boot/grub
	cp $(KERNEL) iso/boot/$(notdir $(KERNEL))
	cp resources/grub.cfg iso/boot/grub
	$(GRUB_MKRESCUE) -o $(ISO) iso
ifeq ($(RUNONDONE), 1)
	$(QEMU)
endif

$(KERNEL): $(COBJECTS) $(AOBJECTS) $(NASMOBJECTS)
	mkdir -p build
	$(LD) $(LDFLAGS) $(AOBJECTS) $(COBJECTS) $(NASMOBJECTS) $(LIBGCC) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<

%.ao: %.S
	$(CC) $(CFLAGS) -o $@ -c $<

%.aso: %.asm
	$(AS) $(ASFLAGS) -o $@ $<

qemu: $(ISO) 
	$(QEMU)

clean:
	rm -rf iso
	rm -rf build
	find src/ -type f -name "*o" -delete
	rm -f $(ISO)
