#include <drivers/pit.h>
#include <hw.h>
#include <kernel/irq.h>
#include <printf.h>
#include <stdint.h>
#include <tasking/tasking.h>

// Amount of milliseconds the system has been running for

uint64_t timer_ticks = 0;
void timer_handler() {
  outb(0x20, 0x20);
  timer_ticks++;
  if ((timer_ticks % 1000) == 0) {
    schedule();
  }
}

// Set timer interrupt rate in hertz
void timer_phase(int hz) {
  int divisor = 1193180 / hz;
  outb(0x43, 0x36);
  outb(0x40, divisor & 0xFF);
  outb(0x40, divisor >> 8);
}

// Sleep for X milliseconds
void sleep(uint64_t milliseconds) {
  unsigned int ticks;
  ticks = timer_ticks + milliseconds;
  while (timer_ticks < ticks)
    ;
  printf(""); // REVIEW: I don't know why bit if this isn't here it just goes
              // through the loop. I think the compiler is optimizing it out.
              // Can someone find a workaround?
}

// Initialize PIT
int init_pit() {
  timer_phase(1000);
  irq_install_handler(0, timer_handler);
  return 0;
}
