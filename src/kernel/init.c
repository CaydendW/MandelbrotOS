#include <font.h>
#include <kernel/init.h>
#include <kernel/kpanic.h>
#include <kernel/text.h>
#include <kernel/vbe.h>
#include <macros.h>
#include <stdbool.h>
#include <string.h>

int inited_funs_no;
const char *inited_funcs[50];

void init_check(int func, char *name, bool ness) {
  printf("Initializing %s", name);
  if (func == 0) {
    // x = fb_width - 54;
    x = (int)fb_width - ((GLYPH_WIDTH + 1) * 6) - 2;
    printf("[ ");
    fg_color = GREEN;
    printf("OK");
    fg_color = FG;
    printf(" ]");

    inited_funcs[inited_funs_no] = name;
    inited_funs_no++;
  } else {
    x = (int)fb_width - ((GLYPH_WIDTH + 1) * 10) - 2;
    printf("[ ");
    fg_color = RED;
    printf("FAILED");
    fg_color = FG;
    printf(" ]");
    if (ness) {
      // TODO: output the name
      kpanic("failed to initialize", 19);
    }
  }
}
