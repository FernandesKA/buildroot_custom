################################################################################
#
# aerolith
#
################################################################################

AEROLITH_VERSION = 63a735bb4902ebda278aa731f6065a9fe13f703f
AEROLITH_SITE = $(call github,FernandesKA,aerolith,$(AEROLITH_VERSION))
AEROLITH_LICENSE = Unknown
AEROLITH_DEPENDENCIES = python3

# Pure Python, nothing to build.
define AEROLITH_BUILD_CMDS
	:
endef

# Installed as a single-level package dir (/usr/local/lib/aerolith/*.py),
# matching the project's own "cd /usr/local/lib && python3 -m aerolith.main"
# instructions. Upstream's S99aerolith sets PYTHONPATH to that same
# /usr/local/lib/aerolith dir instead of its parent, which would make
# "-m aerolith.main" fail to find the aerolith package -- fix it up here
# to match the single-level layout we actually install.
define AEROLITH_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/usr/local/lib/aerolith
	cp -a $(@D)/aerolith/. $(TARGET_DIR)/usr/local/lib/aerolith/
	$(INSTALL) -D -m 0755 $(@D)/buildroot/S99aerolith \
		$(TARGET_DIR)/etc/init.d/S99aerolith
	sed -i 's|^APP_DIR=.*|APP_DIR=/usr/local/lib|' \
		$(TARGET_DIR)/etc/init.d/S99aerolith
endef

$(eval $(generic-package))
