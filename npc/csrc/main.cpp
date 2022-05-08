#include <stdio.h>
#include <stdlib.h>
#include "Vtop.h"
#include "verilated.h"
#include "nvboard.h"

static TOP_NAME top;

void nvboard_bind_all_pins(Vtop* top);

static void single_cycle(){
	top.clk = 0;
	top.eval();
	top.clk = 1;
	top.eval();
}

static void reset(int n){
	top.rst = 1;
	while(n > 0){
		single_cycle();
		n--;
	}
	top.rst = 0;

}


int main(){
	nvboard_bind_all_pins(&top);
	nvboard_init();
	reset(10);
	while(1){
		nvboard_update();
		single_cycle();
	}
}
