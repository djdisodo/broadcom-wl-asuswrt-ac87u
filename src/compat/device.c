#include <linux/device.h>
void compat_dev_set_drvdata(struct device *dev, void *data) {
	dev_set_drvdata(dev, data);
}

void *compat_dev_get_drvdata(struct device *dev) {
	return dev_get_drvdata(dev);
}
