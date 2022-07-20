#include "common.h"
#include "memory/paddr.h"
#include <assert.h>
#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

enum {
  TK_NOTYPE = 256,
  /* TODO: Add more token types */
  TK_PLUS,TK_MINUS, 
  TK_MULTIPLY,TK_DIVIDE,
  TK_LEFT_PARENTHES,TK_RIGHT_PARENTHES,
  TK_DIGIT,TK_REG,TK_HEXNUM,
  TK_EQ,TK_DEQ,TK_AND,TK_OR,
  TK_REF,


};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +", TK_NOTYPE},    // spaces
  {"\\+", TK_PLUS},         // plus
  //{"==", TK_EQ},        // equal
  {"0x[a-z,0-9]+",TK_HEXNUM},
  {"[0-9]+",TK_DIGIT},
  {"-",TK_MINUS},
  {"\\*",TK_MULTIPLY},
  {"\\(",TK_LEFT_PARENTHES},
  {"\\)",TK_RIGHT_PARENTHES},
  {"/",TK_DIVIDE},
  {"\\$[a-z,0-9]{2,3}",TK_REG},
  {"==",TK_EQ},
  {"!=",TK_DEQ},
  {"\\|\\|",TK_OR},
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[3200] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;
  for (int l = 0; l < 3200; l++) memset(tokens[l].str,'\0',sizeof(tokens[l].str));

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

        Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */

        switch (rules[i].token_type) {
			case TK_NOTYPE:
				break;
          default: 
				tokens[nr_token].type = rules[i].token_type; 
				strncpy(tokens[nr_token].str,substr_start,substr_len);
				nr_token++;
				break;
        }
        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }
  for (int j = 0; j < nr_token; j++){
	  if (tokens[j].type == TK_MULTIPLY &&(j == 0 || (tokens[j-1].type != TK_DIGIT
					  &&tokens[j-1].type!=TK_HEXNUM && tokens[j-1].type!=TK_REG
					  && tokens[j-1].type != TK_RIGHT_PARENTHES))) tokens[j].type = TK_REF;
  }


  return true;
}

int op_level(int type){
	switch(type){
		case TK_EQ: 
			return 0;
		case TK_DEQ:
			return 0;
		case TK_AND:
			return 0;
		case TK_OR:
			return 0;
		case TK_MINUS:
			return 1;
		case TK_PLUS:
			return 1;
		case TK_DIVIDE:
			return 2;
		case TK_MULTIPLY:
			return 2;
		case TK_REF:
			return 3;
		default:
			assert(0);
	}
}

bool check_parentheses(int p,int q){
	if (!(tokens[p].type == TK_LEFT_PARENTHES && tokens[q].type == TK_RIGHT_PARENTHES)) return false;
	int left = 0;
	for (int i = p; i <= q; i++){
		if (tokens[i].type == TK_LEFT_PARENTHES) left++;
		if (tokens[i].type == TK_RIGHT_PARENTHES) left--;
		if (left<0) {
			printf("bad expression in check_parentheses\n");
			assert(0);
		}
		if (left == 0 && i!= q) return false;
	}
	return true;
}


int getMop(int p, int q){
	int ops[9] = {TK_PLUS,TK_MINUS,TK_MULTIPLY,TK_DIVIDE,
					TK_EQ,TK_DEQ,TK_AND,TK_OR,TK_REF};
	int pos = p;
	int op = TK_REF;
	int left = 0;
	for (int i = p; i <= q; i++){
		if (tokens[i].type == TK_LEFT_PARENTHES) left++;
		if (tokens[i].type == TK_RIGHT_PARENTHES) left--;
		if (left>0) continue;
		for (int j = 0; j < 4; j++){
			if (ops[j] == tokens[i].type){
				if ( op_level(op)>= op_level(ops[j])){
					op = ops[j];
					pos = i;
				}
			}
		}
	}
	return pos;
}

word_t eval(int p,int q){
	if (p > q) {
	// print_tokens();
		printf("bad expression in eval\n");
		assert(0);
	}
	else if (p == q){
		word_t num;
		bool success = true;
		char regname[5];
		switch (tokens[p].type){
			case TK_DIGIT:
				sscanf(tokens[p].str,"%lu",&num);
				return num;
			case TK_HEXNUM:
				sscanf(tokens[p].str,"0x%lx",&num);
				return num;
			case TK_REG:
				sscanf(tokens[p].str,"$%s",regname);
				num = isa_reg_str2val(regname,&success);
				assert(success==true);
				return num;
			default:
				assert(0);
		}
	}
	else if (check_parentheses(p,q)){
		return eval(p+1,q-1);
	}
	else {
		int pos = getMop(p,q);
		if (pos == p){
			unsigned right = eval(pos+1,q);
			switch (tokens[p].type){
				case TK_REF:
					return paddr_read(right, 8);
				default:assert(0);
			}
		}
		unsigned left = eval(p,pos-1);
		if (left == 0 && tokens[pos].type == TK_MULTIPLY) return 0;
		unsigned right = eval(pos+1,q);
		switch (tokens[pos].type){
			case TK_PLUS:
				return left+right;
			case TK_MINUS:
				return left-right;
			case TK_MULTIPLY:
				return left*right;
			case TK_DIVIDE:
				return left/right;
			case TK_EQ:
				return left == right;
			case TK_DEQ:
				return left!= right;
			case TK_OR:
				return left||right;
			default:
				assert(0);
		}
	}
}
word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  /* TODO: Insert codes to evaluate the expression. */
  word_t val = eval(0,nr_token-1);
  // printf("%s = %d\n",e,(int)val);
  return val;
}

