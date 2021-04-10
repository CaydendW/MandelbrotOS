#include <hw.h>
#include <kernel/idt.h>
#include <kernel/irq.h>

void *irq_routines[16] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

extern void irq_0();
extern void irq_1();
extern void irq_2();
extern void irq_3();
extern void irq_4();
extern void irq_5();
extern void irq_6();
extern void irq_7();
extern void irq_8();
extern void irq_9();
extern void irq_10();
extern void irq_11();
extern void irq_12();
extern void irq_13();
extern void irq_14();
extern void irq_15();

void irq_remap(void) {
  outb(0x20, 0x11);
  outb(0xA0, 0x11);
  outb(0x21, 0x20);
  outb(0xA1, 0x28);
  outb(0x21, 0x04);
  outb(0xA1, 0x02);
  outb(0x21, 0x01);
  outb(0xA1, 0x01);
  outb(0x21, 0x0);
  outb(0xA1, 0x0);
}

int init_irq() {
  irq_remap();

  idt_set_entry(&idt[32 + 0], irq_0);
  idt_set_entry(&idt[32 + 1], irq_1);
  idt_set_entry(&idt[32 + 2], irq_2);
  idt_set_entry(&idt[32 + 3], irq_3);
  idt_set_entry(&idt[32 + 4], irq_4);
  idt_set_entry(&idt[32 + 5], irq_5);
  idt_set_entry(&idt[32 + 6], irq_6);
  idt_set_entry(&idt[32 + 7], irq_7);
  idt_set_entry(&idt[32 + 8], irq_8);
  idt_set_entry(&idt[32 + 9], irq_9);
  idt_set_entry(&idt[32 + 10], irq_10);
  idt_set_entry(&idt[32 + 11], irq_11);
  idt_set_entry(&idt[32 + 12], irq_12);
  idt_set_entry(&idt[32 + 13], irq_13);
  idt_set_entry(&idt[32 + 14], irq_14);
  idt_set_entry(&idt[32 + 15], irq_15);

  return 0;
}

void irq_install_handler(int irq, void(*handler)) {
  irq_routines[irq] = handler;
}

void irq_uninstall_handler(int irq) { irq_routines[irq] = 0; }

void irq_handler(int irq_no) {
  void (*handler)();
  handler = irq_routines[irq_no];

  if (handler)
    handler();

  if (irq_no >= 8) {
    outb(0xA0, 0x20);
  }
  outb(0x20, 0x20);
}