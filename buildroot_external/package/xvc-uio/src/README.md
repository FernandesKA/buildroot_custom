This is an empty placeholder source tree for the xvc-uio Buildroot
package. xvc-uio does not build any code of its own: it only enables
the Linux kernel's built-in generic UIO framework (CONFIG_UIO,
CONFIG_UIO_PDRV_GENIRQ) so that a "debug_bridge" (or other) AXI IP
core exposed via a "generic-uio" device tree node can be mmap()'d
from user space, e.g. by xvcServer_mmap from the xvc-server package.
