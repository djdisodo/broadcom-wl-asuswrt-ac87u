#include <linux/netdevice.h>

struct net_device *compat_alloc_netdev_mq(int sizeof_priv, const char *name,
				       void (*setup)(struct net_device *),
				       unsigned int queue_count) {
	return alloc_netdev_mq(sizeof_priv, name, NET_NAME_UNKNOWN, setup, queue_count);
}
