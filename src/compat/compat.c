//these aren't used anymore; only symbols exists
int num_physpages[0], _raw_spin_unlock[0], dnsmq_hit_hook[0], cpu_online_mask[0], ctf_attach_fn[0];


#include <string.h>
void __memzero(void *ptr, int n) {
	memset(ptr, 0, n);
}

void
__arm_ioremap(unsigned long phys_addr, size_t size, unsigned int mtype) {}

void __iounmap(volatile void __iomem *io_addr) {}

//ignore
void warn_slowpath_null(const char *file, const int line) {
	
}
