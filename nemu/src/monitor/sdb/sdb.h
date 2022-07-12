#ifndef __SDB_H__
#define __SDB_H__

#include <common.h>

word_t expr(char *e, bool *success);

#define NR_WP 32

typedef struct watchpoint {
  int NO;
  struct watchpoint *next;

  /* TODO: Add more members if necessary */
  char e[100];
  word_t val;

} WP;

WP *new_wp(char *e);
void free_wp(WP *wp);
void delete_wp(int n);
#endif
