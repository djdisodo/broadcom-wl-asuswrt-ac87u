#include <linux/workqueue.h>
bool compat_schedule_work_on(int cpu, struct work_struct *work)
{
	return queue_work_on(cpu, system_wq, work);
}

void compat_flush_scheduled_work(void) {
	flush_scheduled_work();
}

bool compat_schedule_work(struct work_struct *work) {
	return schedule_work(work);
}