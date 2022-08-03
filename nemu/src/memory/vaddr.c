#include <isa.h>
#include <memory/paddr.h>

#define IMBUF_SIZE 5
static char mbuf[IMBUF_SIZE][128];
static int r = 0;

word_t vaddr_ifetch(vaddr_t addr, int len) {
	//sprintf(mbuf[r++],"read memory: %016lx",addr);
  return paddr_read(addr, len);
}

word_t vaddr_read(vaddr_t addr, int len) {
	word_t data = paddr_read(addr,len);
	sprintf(mbuf[r++],"    read  memory: %016lx,%016lx",addr,data);
	r = r%IMBUF_SIZE;
  return paddr_read(addr, len);
}

void vaddr_write(vaddr_t addr, int len, word_t data) {
	r = r%IMBUF_SIZE;
	sprintf(mbuf[r++],"    write memory: %016lx,%016lx",addr,data);
  paddr_write(addr, len, data);
}

void get_mtrace(){
	memmove(mbuf[(r-1+IMBUF_SIZE)%IMBUF_SIZE],"-->",3);
	for (int i = 0; i < IMBUF_SIZE; i++){
		printf("%s\n",mbuf[i]);
	}
}
