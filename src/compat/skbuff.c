#include <linux/skbuff.h>
struct sk_buff *compat_dev_alloc_skb(unsigned int length)
{
	return dev_alloc_skb(length);
}
