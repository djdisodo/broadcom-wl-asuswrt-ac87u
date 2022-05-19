#include <linux/bitops.h>
void _set_bit_le(int nr, void *addr) {
	set_bit_le(nr, addr);
}

int _test_and_set_bit_le(int nr, volatile unsigned long * p) {
	return test_and_set_bit_le(nr, p);
}

int _test_and_clear_bit_le (int nr, volatile unsigned long * p) {
	return test_and_clear_bit_le(nr, p);
}