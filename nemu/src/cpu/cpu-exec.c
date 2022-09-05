#include "common.h"
#include "cpu/ifetch.h"
#include "macro.h"
#include "memory/paddr.h"
#include "utils.h"
#include <cpu/cpu.h>
#include <cpu/decode.h>
#include <cpu/difftest.h>
#include <locale.h>
/* The assembly code of instructions executed is only output to the screen
 * when the number of instructions executed is less than this value.
 * This is useful when you use the `si' command.
 * You can modify this value as you want.
 */
#define MAX_INST_TO_PRINT 10

CPU_state cpu = {};
uint64_t g_nr_guest_inst = 0;
static uint64_t g_timer = 0; // unit: us
static bool g_print_step = false;

void device_update();
bool test_chanage();
// here mycode
#define IRING_BUFSIZE 5
static char rinsts[IRING_BUFSIZE][128];
static int r = 0;

#define FBUF_SIZE 1000
static char ftrace[FBUF_SIZE][128];
static int fr = 0;

int level = 0;

static void trace_and_difftest(Decode *_this, vaddr_t dnpc) {
#ifdef CONFIG_ITRACE_COND
	memset(rinsts[r],' ',4);
	strcpy(rinsts[r++] + 4,_this->logbuf);
	r = r%IRING_BUFSIZE;
  if (ITRACE_COND) { log_write("%s\n", _this->logbuf); }
#endif
  if (g_print_step) { IFDEF(CONFIG_ITRACE, puts(_this->logbuf)); }
  IFDEF(CONFIG_DIFFTEST, difftest_step(_this->pc, dnpc));
#ifdef CONFIG_CC_WATCHPOINT
  if (test_chanage()){
	  nemu_state.state = NEMU_STOP;
	  printf("watchpoint changed\n");
  }
#endif

}

static void exec_once(Decode *s, vaddr_t pc) {
  s->pc = pc;
  s->snpc = pc;
  isa_exec_once(s);
  cpu.pc = s->dnpc;
#ifdef CONFIG_ITRACE
  char *p = s->logbuf;
  p += snprintf(p, sizeof(s->logbuf), FMT_WORD ":", s->pc);
  int ilen = s->snpc - s->pc;
  int i;
  uint8_t *inst = (uint8_t *)&s->isa.inst.val;
  for (i = ilen - 1; i >= 0; i --) {
    p += snprintf(p, 4, " %02x", inst[i]);
  }
  int ilen_max = MUXDEF(CONFIG_ISA_x86, 8, 4);
  int space_len = ilen_max - ilen;
  if (space_len < 0) space_len = 0;
  space_len = space_len * 3 + 1;
  memset(p, ' ', space_len);
  p += space_len;

  void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
  disassemble(p, s->logbuf + sizeof(s->logbuf) - p,
      MUXDEF(CONFIG_ISA_x86, s->snpc, s->pc), (uint8_t *)&s->isa.inst.val, ilen);
#endif

#ifdef CONFIG_FTRACE
  extern int elf_read;
  assert(elf_read);
  void elf_func_name(uint64_t addr,char *name);
  unsigned instval = s->isa.inst.val;
  if (instval == 0x00008067 || BITS(instval, 6, 0)==0b1101111 || 
		  (BITS(instval, 6, 0) == 0b1100111 && BITS(instval, 14, 12)==0b000))
  {
	char * ftp = ftrace[fr++];
	// printf("fr = %d,level = %d\n",fr,level);
  	char name[128];
  	if (instval==0x00008067){
  	    elf_func_name(s->pc,name);
  	    level--;
		ftp += sprintf(ftp,"0x%016lx:",s->pc);
		for (int i = 0; i < level;i++) ftp += sprintf(ftp,"  ");
  	    ftp += sprintf(ftp,"ret [%s]",name);
		printf("%s\n",ftrace[fr-1]);
  	}
  	else if(BITS(instval,6,0)==0b1101111 || 
  	  	  (BITS(instval,6,0)==0b1100111 && BITS(instval,14,12)==0b000)){
  	    // printf("pc = 0x%016lx,dnpc = 0x%016lx\n",s->pc,s->dnpc);
  	    elf_func_name(s->dnpc,name);
		ftp += sprintf(ftp,"0x%016lx:",s->pc);
		for (int i = 0; i < level;i++) ftp += sprintf(ftp,"  ");
  	    ftp += sprintf(ftp,"call [%s@0x%016lx]",name,s->dnpc);
		printf("%s\n",ftrace[fr-1]);
  	    level++;
  	}
  }
#endif

//   char *q = s->logbuf;
//   q += snprintf(q,sizeof(s->logbuf),FMT_WORD ":",s->pc);
//   int instlen = s->snpc - s->pc;
//   uint8_t *insts = (uint8_t *)&s->isa.inst.val;
//   for (int j = instlen - 1; j>=0; j--){
// 	  q += snprintf(q,4," %02x",insts[j]);
//   }
//   int instlen_max = MUXDEF(CONFIG_ISA_x86, 8, 4);
//   int s_len = instlen_max -instlen;
//   if (s_len < 0) s_len = 0;
//   s_len = s_len*3 + 1;
//   memset(q,' ',s_len);
//   q += s_len;
// #ifndef CONFIG_ITRACE
//   void disassemble(char *str,int size,uint64_t pc,uint8_t *code,int nbyte);
// #endif
//   disassemble(q,s->logbuf + sizeof(s->logbuf) - q,
// 		  MUXDEF(CONFIG_ISA_x86, s->snpc,s->pc),(uint8_t *)&s->isa.inst.val,instlen);
}
static void execute(uint64_t n) {
  Decode s;
  for (;n > 0; n --) {
    exec_once(&s, cpu.pc);
    g_nr_guest_inst ++;
    trace_and_difftest(&s, cpu.pc);
    if (nemu_state.state != NEMU_RUNNING) break;
    IFDEF(CONFIG_DEVICE, device_update());
  }
}

static void statistic() {
  IFNDEF(CONFIG_TARGET_AM, setlocale(LC_NUMERIC, ""));
#define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%ld", "%'ld")
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("total guest instructions = " NUMBERIC_FMT, g_nr_guest_inst);
  if (g_timer > 0) Log("simulation frequency = " NUMBERIC_FMT " inst/s", g_nr_guest_inst * 1000000 / g_timer);
  else Log("Finish running in less than 1 us and can not calculate the simulation frequency");
  get_mtrace();
}

void assert_fail_msg() {
  isa_reg_display();
  statistic();
}

/* Simulate how the CPU works. */
void cpu_exec(uint64_t n) {
  g_print_step = (n < MAX_INST_TO_PRINT);
  switch (nemu_state.state) {
    case NEMU_END: case NEMU_ABORT:
      printf("Program execution has ended. To restart the program, exit NEMU and run again.\n");
      return;
    default: nemu_state.state = NEMU_RUNNING;
  }

  uint64_t timer_start = get_time();

  execute(n);

  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;


  switch (nemu_state.state) {
    case NEMU_RUNNING: nemu_state.state = NEMU_STOP; break;

    case NEMU_END: case NEMU_ABORT:
      Log("nemu: %s at pc = " FMT_WORD,
          (nemu_state.state == NEMU_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (nemu_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          nemu_state.halt_pc);
		if (nemu_state.state == NEMU_ABORT || nemu_state.halt_ret!=0){
			memmove(rinsts[(r-1+IRING_BUFSIZE)%IRING_BUFSIZE],"-->",3);
			for (int i = 0; i < IRING_BUFSIZE; i++){
				printf("%s\n",rinsts[i]);
			}
#ifdef CONFIG_FTRACE
			for (int i =0; i < fr;i++){
				printf("%s\n",ftrace[i]);
			}
#endif
		}


      // fall through
    case NEMU_QUIT: statistic();
  }
}
