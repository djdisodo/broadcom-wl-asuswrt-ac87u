#include <linux/types.h>
/*
notes: it might be a different type with same width; ex. uint32_t <-> void *, bool <-> uint8_t
it shouldn't matter as long as it's running on same arch
*/
typedef uint32_t undefined4;
typedef uint8_t undefined1;
typedef void undefined;
typedef void code;