#include <linux/uaccess.h>

unsigned long
compat__copy_to_user(void __user *to, const void *from, unsigned long n) {
	return __copy_to_user(to, from, n);
}

unsigned long
compat__copy_from_user(void *to, const void __user *from, unsigned long n) {
	return __copy_from_user(to, from, n);
}
