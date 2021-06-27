#include <asm.h>
#include <boot/stivale2.h>
#include <fb/fb.h>
#include <kernel/gdt.h>
#include <kernel/idt.h>
#include <kernel/irq.h>
#include <kernel/isr.h>
#include <printf.h>
#include <stddef.h>
#include <stdint.h>
#include <drivers/pit.h>
#include <drivers/pcspkr.h>

void *stivale2_get_tag(struct stivale2_struct *stivale2_struct, uint64_t id) {
  struct stivale2_tag *current_tag = (void *)stivale2_struct->tags;
  while (1) {
    if (!current_tag) {
      return NULL;
    } else if (current_tag->identifier == id) {
      return current_tag;
    }
    current_tag = (void *)current_tag->next;
  }
}

void kernel_main(struct stivale2_struct *bootloader_info) {
  init_gdt();
  init_idt();
  init_isr();
  init_irq();
  asm volatile("sti");
  struct stivale2_struct_tag_framebuffer *framebuffer_info =
      (struct stivale2_struct_tag_framebuffer *)stivale2_get_tag(
          bootloader_info, STIVALE2_STRUCT_TAG_FRAMEBUFFER_ID);

  init_fb(framebuffer_info);
  init_pit();
  outb(0x61, inb(0x61) | 0x1);
  pcspkr_beep(400);

  printf("Hello, world!\r\n");
  printf("Dividing by 0 in 5 seconds.");
  sleep(5000);
  printf("NOW! %i", 10/0);

  while (1)
    ;
}
