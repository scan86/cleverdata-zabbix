INSTALL=/usr/bin/install

DEPS_ROOT=/srv/scripts/zabbix
CONF_DIR=/etc/zabbix/zabbix_agentd.d

all: nothing

install: make_dirs put_files

make_dirs:
	$(INSTALL) -m 0755 -d $(DESTDIR)$(DEPS_ROOT)
	$(INSTALL) -m 0755 -d $(DESTDIR)$(CONF_DIR)

put_files:
	$(INSTALL) -m 0755 check_java_proc.sh $(DESTDIR)$(DEPS_ROOT)
	$(INSTALL) -m 0644 check_java_proc.conf $(DESTDIR)$(CONF_DIR)

nothing:
	exit 0
