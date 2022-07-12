#include <isa.h>
#include <cpu/cpu.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <sys/types.h>
#include "common.h"
#include "memory/paddr.h"
#include "sdb.h"

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();
void delete_wp(int n);
void display_watch();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}


static int cmd_q(char *args) {
  return -1;
}

static int cmd_help(char *args);

static int cmd_si(char *args){
	char *arg = strtok(NULL," ");
	if (arg == NULL){
		cpu_exec(1);
	}
	else {
		int n = atoi(arg);
		cpu_exec(n);
	}
	return 0;
}

static int cmd_info(char *args){
	char *arg = strtok(NULL," ");
	if (arg == NULL){
		return -1;
	}
	else {
		if (strcmp(arg,"r")==0) {
			isa_reg_display();
		}
		else if (strcmp(arg,"w") == 0){
			display_watch();
		}
		else {
			return -1;
		}
	}
	return 0;
}

static int cmd_x(char *args){
	char *arg = strtok(NULL," ");
	if (arg == NULL){
		return -1;
	}
	else {
		int n = atoi(arg);
		arg = strtok(NULL," ");
		paddr_t paddr;
		sscanf(arg,FMT_PADDR,&paddr);
		for (int i = 0; i < n; i ++){
			if (i%8==0) printf(FMT_PADDR": ",paddr+i);
			printf("%02x",(unsigned char)paddr_read(paddr+i,1));
			if ((i+1)%8==0) printf("\n");
			else printf("\t");
		}
		printf("\n");
	}
	return 0;
}
static int pcnt = 0;
static int cmd_p(char *args){
	char *arg = strtok(NULL,"\n");
	if (arg == NULL){
		return -1;
	}
	else {
		bool success = true;
		word_t val = expr(arg,&success);
		if (success) printf("$%d = %lu, hex =0x%016lx\n",pcnt++,val,val);
		else return -1;
	}
	return 0;
}

static int cmd_watch(char *args){
	char *arg = strtok(NULL," ");
	if (arg == NULL){
		return -1;
	}
	else {
		new_wp(arg);
	}
	return 0;
}

static int cmd_dw(char *args){
	char *arg = strtok(NULL," ");
	if (arg == NULL){
		return -1;
	}
	else{
		int num = atoi(arg);
		delete_wp(num);
	}
	return 0;
}



static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display informations about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit NEMU", cmd_q },

  /* TODO: Add more commands */
  {"si", "Exec N steps, N default 1",cmd_si},
  {"info", "Print register state or watchpoint",cmd_info},
  {"x","Print memory",cmd_x},
  {"p","Print expr val",cmd_p},
  {"w", "watch expr",cmd_watch},
  {"d", " delete watchpoint",cmd_dw},

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}

void sdb_set_batch_mode() {
  is_batch_mode = true;
}

void sdb_mainloop() {
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }

  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}
