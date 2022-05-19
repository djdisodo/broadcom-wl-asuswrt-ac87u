#include <linux/proc_fs.h>
//not used anymore; only symbol exists
struct proc_dir_entry *create_proc_entry(const char *name, mode_t mode,
						struct proc_dir_entry *parent) {
	return NULL;
}
