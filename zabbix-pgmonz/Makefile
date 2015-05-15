INSTALL="/usr/bin/install"

DEPS_ROOT="/srv/scripts/zabbix"
CONF_DIR="/etc/zabbix/zabbix_agentd.d"
SHARE_DIR="/usr/share/zabbix-pgmonz"

all: nothing

install: make_dirs put_files

make_dirs:
	$(INSTALL) -m 0755 -d $(DESTDIR)$(DEPS_ROOT)
	$(INSTALL) -m 0755 -d $(DESTDIR)$(CONF_DIR)
	$(INSTALL) -m 0755 -d $(DESTDIR)$(SHARE_DIR)
	

put_files:
	cp -ir pg_monz $(DESTDIR)$(DEPS_ROOT)
	cp -i userparameter_pgsql.conf $(DESTDIR)$(CONF_DIR)
	cp -i zbx_template.xml $(DESTDIR)$(SHARE_DIR) 

nothing:
	exit 0
