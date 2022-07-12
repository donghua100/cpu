#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>

// this should be enough
static char buf[65536] = {};
static char tmp_buf[65536] = {};
static char code_buf[65536 + 12800] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"#include <signal.h>\n"
"#include <setjmp.h>\n"
"jmp_buf buf;"
"void sighandler(int sig){"
"	longjmp(buf,sig);"
"}"
"int main() { "
"	signal(SIGFPE,sighandler);"
"	int ret = setjmp(buf);"
"	if (ret == 0) {"
"		unsigned result = %s; "
"		printf(\"%%u\", result); "
"	}"
"  return 0; "
"}";

static char *p = buf;
static char *pp = tmp_buf;
static char ops[4] = {'+','-','*','/'};
static int it = 0;

static void gen_rand_expr() {
	int num = rand()%3;
	if (it <= 3) num = rand()%2 + 1;
	if (it >= 10) num = 0;
	if (rand()%2 == 0){
		p += sprintf(p,"%s"," ");
		pp += sprintf(pp,"%s"," ");
	} 
	it++;
	int r;
	switch (num) {
		case 0:
			r = rand()%129;
			p += sprintf(p,"%d",r);
			pp += sprintf(pp,"%dU",r);
			break;
		case 1:
			p += sprintf(p,"(");
			pp += sprintf(pp,"(");
			gen_rand_expr();
			p += sprintf(p,")");
			pp += sprintf(pp,")");
			break;
		default:
			gen_rand_expr();
			r = rand()%4;
			p += sprintf(p,"%c",ops[r]);
			pp += sprintf(pp,"%c",ops[r]);
			gen_rand_expr();

			break;
	}
}

int main(int argc, char *argv[]) {
  int seed = time(0);
  srand(seed);
  int loop = 1;
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  for (i = 0; i < loop; i ++) {
	  
	memset(buf, '\0',sizeof(buf));
	memset(tmp_buf, '\0',sizeof(tmp_buf));
	p = buf;
	pp = tmp_buf;
	it = 0;
    gen_rand_expr();

    sprintf(code_buf, code_format, tmp_buf);

    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    int ret = system("gcc /tmp/.code.c -o /tmp/.expr");
    if (ret != 0) continue;

    fp = popen("/tmp/.expr", "r");
    assert(fp != NULL);

    int result;
    ret = fscanf(fp, "%d", &result);
    pclose(fp);
	if (ret!=-1) printf("%u %s\n", result, buf);
  }
  return 0;
}
