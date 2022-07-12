#include "sdb.h"
#include <assert.h>

static WP wp_pool[NR_WP] = {};
static WP dummy,dummy_f;
static WP *head = NULL, *free_ = NULL;
void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
  }

  head = &dummy;
  free_ = &dummy_f;
  free_->next = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */


WP* new_wp(char *e) {
	WP * p = free_->next;
	assert(p!=NULL);
	// delete from free_
	free_->next = free_->next->next;
	
	// add to head
	p->next = head->next;
	head->next = p;

	strcpy(p->e,e);
	bool success = true;
	p->val = expr(e, &success);
	return p;
}

void free_wp(WP *wp){
	WP * p = head;
	while(p!=NULL){
		if (p->next==wp){
			// delete from head
			p->next = p->next->next;

			// add to free_
			wp->next = free_->next;
			free_->next = wp;

			break;
		}
		p = p->next;
	}
}

void delete_wp(int n){
	WP *p = head->next;
	while(p!=NULL){
		if (p->NO == n){
			free_wp(p);
			break;
		}
		p = p->next;
	}
}


void display_watch(){
	WP * p = head->next;
	while(p!=NULL){
		printf("watchpoint %d: %s = %lu,hex = 0x%016lx\n",p->NO,p->e,p->val,p->val);
		p = p->next;
	}
}

bool test_chanage(){
	WP * p = head->next;
	bool flag = false;
	while(p!=NULL){
		bool sucess = true;
		word_t now = expr(p->e,&sucess);
		if (p->val!=now){
			flag = true;
		}
		p = p->next;
	}
	return flag;
}

