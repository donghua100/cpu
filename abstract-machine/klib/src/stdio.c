#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	char * p = out; 
	int res = 0;
	while(*fmt!='\0'){
		if(*fmt=='%'){
			fmt++;
			if(*fmt=='%'){
				*p++=*fmt++;
				res++;
			}
			else {
				if(*fmt=='d'){
					int val = va_arg(ap, int);
					if (val == 0) *p++='0';
					if(val < 0){
						*p++='-';
						res++;
						val = abs(val);
					}
					char nums[20] = {};
					int len = 0;
					while(val){
						nums[len++] = val%10 + '0';
						val /= 10;
					}
					while(len--){
						*p++=*(nums+len);
						res++;
					} 
				}
				else if (*fmt=='s'){
					char * s = va_arg(ap, char *);
					while(*s!='\0'){
						*p++=*s++;
						res++;
					} 
				}
			}
		}
		else {
			*p++=*fmt++;
			res++;
		}
		va_end(ap);
	}
	return res;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
