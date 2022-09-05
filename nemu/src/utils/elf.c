#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <elf.h>


typedef struct {
	Elf64_Addr f_addr;
	char f_name[128];
	uint64_t f_size;
} Func_info;


static Func_info func_info[128];

static int r = 0;
int elf_read = 0;
void read_name(unsigned idx,const char *tab,char *name){
	while(*(tab+idx)!='\0') *name++=*(tab+idx++);
	*name='\0';
}

void elf_set(){
	elf_read = 1;
}

void init_elf(const char *file){
	int rr = 0;
	FILE *fp = fopen(file,"r");
	assert(fp!=NULL);
	Elf64_Ehdr header;
	rr = fread(&header,sizeof(Elf64_Ehdr),1,fp);
	Elf64_Off e_shoff = header.e_shoff;
	uint16_t e_shentsize = header.e_shentsize;
	uint16_t e_shnum = header.e_shnum;
	uint16_t e_shstrndx = header.e_shstrndx;
#ifdef PRINTELF
	printf("section header table offset:%ld (0x%lx)\n",e_shoff,e_shoff);
	printf("Size of section header:%d\n",e_shentsize);
	printf("Number of section headers:%d\n",e_shnum);
	printf("Section header string table index:%d\n",e_shstrndx);
#endif
	rr = fseek(fp,e_shoff+e_shstrndx*e_shentsize, SEEK_SET);
	Elf64_Shdr elf64_shdr;
	rr = fread(&elf64_shdr,sizeof(Elf64_Shdr),1,fp);
	Elf64_Off sh_offset = elf64_shdr.sh_offset;
	uint64_t sh_size = elf64_shdr.sh_size;
#ifdef PRINTELF
	printf("Section name strtab offset:%ld (0x%lx)\n",sh_offset,sh_offset);
	printf("Section name strtab size:%ld (0x%lx)\n",sh_size,sh_size);
#endif
	rr = fseek(fp,sh_offset,SEEK_SET);
	char buf[12800];
	memset(buf,'\0',sizeof(buf));
	rr = fread(buf,1,sh_size,fp);
#ifdef PRINTELF
	for (int i = 0; i < sh_size;i++){
		if (buf[i]=='\0') printf("||");
		putchar(buf[i]);
	}
	printf("\n");
#endif
	rr = fseek(fp,e_shoff,SEEK_SET);
	Elf64_Off symtab_off = 0;
	uint64_t symtab_size = 0;
	for (int i = 0; i < e_shnum; i++){
		Elf64_Shdr elf64_shdr;
		rr = fread(&elf64_shdr,1,sizeof(Elf64_Shdr),fp);
		char name[128];
		unsigned j = elf64_shdr.sh_name;
		read_name(j,buf,name);
		if (strcmp(name,".strtab")==0){
			sh_offset = elf64_shdr.sh_offset;
			sh_size = elf64_shdr.sh_size;
		}
		if (strcmp(name,".symtab")==0){
			symtab_off = elf64_shdr.sh_offset;
			symtab_size = elf64_shdr.sh_size;
		}
	}
#ifdef PRINTELF
	printf("strtab offset:%ld (0x%lx)\n",sh_offset,sh_offset);
	printf("strtab size:%ld (0x%lx)\n",sh_size,sh_size);
	printf("symtab offset:%ld (0x%lx)\n",symtab_off,symtab_off);
	printf("symtab size:%ld (0x%lx)\n",symtab_size,symtab_size);
#endif
	memset(buf,'\0',sizeof(buf));
	rr = fseek(fp,sh_offset,SEEK_SET);
	rr = fread(buf,1,sh_size,fp);
#ifdef PRINTELF
	printf("string table:\n");
	for (int i = 0;i < sh_size;i++) {
		if (buf[i]=='\0') printf("||");
		else putchar(buf[i]);
	}
	printf("\n");
#endif
	rr = fseek(fp,symtab_off,SEEK_SET);
	int symtab_entries = symtab_size/sizeof(Elf64_Sym);
	//printf("there are %d symble table entries\n",symtab_entries);
	for (int i = 0; i < symtab_entries;i++){
		Elf64_Sym elf64_sym;
		rr = fread(&elf64_sym,1,sizeof(elf64_sym),fp);
		// printf("%d:st_info = %d\n",i,elf64_sym.st_info);
		if (ELF64_ST_TYPE(elf64_sym.st_info)==STT_FUNC) {
			func_info[r].f_addr = elf64_sym.st_value;
			read_name(elf64_sym.st_name, buf, func_info[r].f_name);
			func_info[r].f_size = elf64_sym.st_size;
			r++;
		}
	}
	rr++;
#ifdef PRINTELF
	printf("there are %d func entries in symble table\n",r);
	printf("%-16s\t\t\t%-32s\t\t\t\t%-s\n","addr","func_name","func_size");
	for (int i =0; i < r;i++){
		printf("0x%016lx\t\t\t%-32s\t\t\t\t%lu\n",func_info[i].f_addr,func_info[i].f_name,func_info[i].f_size);
	}
#endif
}

void elf_func_name(uint64_t addr,char *name){
	// printf("find func name...\n");
	for (int i = 0; i < r; i++){
		if (func_info[i].f_addr<=addr && addr < func_info[i].f_addr + func_info[i].f_size){
			strcpy(name,func_info[i].f_name);
			// printf("func name: %s\n",name);
			return ;
		}
	}
	printf("0x%016lx not a func addr\n",addr);
	assert(0);
}
