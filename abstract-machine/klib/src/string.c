#include <stddef.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
	const char *p = s;
	size_t len = 0;
	while(*p!='\0'){
		len++;
		p++;
	}
	return len;
}

char *strcpy(char *dst, const char *src) {
	int i = 0;
	while(src[i]!='\0'){
		dst[i] = src[i];
		i++;
	}
	dst[i]='\0';
	return dst;
}

char *strncpy(char *dst, const char *src, size_t n) {
	size_t i = 0;
	for (i = 0; i < n && src[i]!='\0';i++){
		dst[i] = src[i];
	}
	for ( ;i < n; i++){
		dst[i] = '\0';
	}
	return dst;

}

char *strcat(char *dst, const char *src) {
	size_t dst_len = strlen(dst);
	size_t i = 0;
	while(src[i]!='\0'){
		dst[i+dst_len] = src[i];
		i++;
	}
	dst[i+dst_len] = '\0';
	return dst;
}

int strcmp(const char *s1, const char *s2) {
	const char *p = s1;
	const char *q = s2;
	while(*p!='\0'&&(*p==*q)){
		p++;
		q++;
	}
	int t = *p - *q;
	return t;
}

int strncmp(const char *s1, const char *s2, size_t n) {
	while(n>0){
		if (*s1=='\0' || *s1!=*s2) return *s1 - *s2;
		s1++;
		s2++;
		n--;
	}
	return 0;
}

void *memset(void *s, int c, size_t n) {
	char * p = s;
	for (int i = 0; i < n; i++){
		*p++ = c;
	}
	return s;
}

void *memmove(void *dst, const void *src, size_t n) {
	char * p = dst;
	const char * q = src;
	if (p < q){
		while(n--){
			*p++=*q++;
		}
	}
	else {
		while(n--){
			*(p+n) = *(q+n);
		}
	}
	return dst;
}

void *memcpy(void *out, const void *in, size_t n) {
	char *p = out;
	const char *q = in;
	while(n--){
		*p++ = *q++;
	}
	return out;
}

int memcmp(const void *s1, const void *s2, size_t n) {
	const char *p = s1;
	const char *q = s2;
	while(n--){
		if(*p!=*q) return *p - *q;
		p++;
		q++;
	}
	return 0;

}

#endif
