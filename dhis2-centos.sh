#!/bin/bash

# EPEL repository files
yum -y install epel-release

# Ansible and related requirements
yum -y -d1 -e0 install -- \
  ansible \
  libselinux-python libsemanage-python \
  python-psycopg2 \
  unzip

# Add 'localhost' to Ansible hosts file
ansible -i 'localhost,' localhost -c local -b -m file -a "path=/etc/ansible state=directory"
ansible -i 'localhost,' localhost -c local -b -m copy -a "dest=/etc/ansible/hosts force=no content=''"
ansible -i 'localhost,' localhost -c local -b -m lineinfile -a "path=/etc/ansible/hosts line='localhost ansible_connection=local'"

# Install main applications: Java, Nginx, Tomcat, PostgreSQL Server
yum -y -d1 -e0 install -- \
  java-1.8.0-openjdk-devel \
  nginx \
  tomcat \
  postgresql-server

# Nginx, Tomcat, and PostgreSQL to start on boot
systemctl enable nginx
systemctl enable tomcat
systemctl enable postgresql

# PostgreSQL: initialize database and setup for local workstation use
ansible localhost -m command -a "postgresql-setup initdb creates=/var/lib/pgsql/data/postgresql.conf"
ansible localhost -m replace -a "path=/var/lib/pgsql/data/pg_hba.conf regexp='^(local\s+.*\s+peer$)' replace='\1 map=local_users'"
ansible localhost -m replace -a "path=/var/lib/pgsql/data/pg_hba.conf regexp='^(host\s+all\s+all\s+.*\s+)ident$' replace='\1 md5'"
ansible localhost -m lineinfile -a "path=/var/lib/pgsql/data/pg_ident.conf line='local_users  postgres  postgres'"
ansible localhost -m lineinfile -a "path=/var/lib/pgsql/data/pg_ident.conf line='local_users  root  postgres'"
ansible localhost -m lineinfile -a "path=/var/lib/pgsql/data/pg_ident.conf line='local_users  root  dhis'"
systemctl start postgresql && sleep 5
ansible localhost -m postgresql_user -a "name=dhis encrypted=yes password=\"{{ lookup('password', '/root/pg_dhis_passwd.txt chars=ascii_letters,digits') }}\""
ansible localhost -m postgresql_db -a "name=dhis2 owner=dhis"

# DHIS2 configuration file for connecting to the database
ansible localhost -m file -a "path=/opt/dhis2 state=directory owner=tomcat group=tomcat"
ansible localhost -m copy -a "dest=/opt/dhis2/dhis.conf owner=tomcat group=tomcat backup=yes content='connection.dialect = org.hibernate.dialect.PostgreSQLDialect
connection.driver_class = org.postgresql.Driver
connection.url = jdbc:postgresql:dhis2
connection.username = dhis
connection.password = {{ lookup('password', '/root/pg_dhis_passwd.txt chars=ascii_letters,digits') }}
connection.schema = update
'"

# Configure Tomcat for '/dev/urandom' -- see https://wiki.apache.org/tomcat/HowTo/FasterStartUp#Entropy_Source
ansible localhost -m lineinfile -a "path=/etc/sysconfig/tomcat line='JAVA_OPTS=\"-Djava.security.egd=file:/dev/./urandom\"'"
ansible localhost -m lineinfile -a "path=/etc/tomcat/tomcat.conf line='JAVA_OPTS=\"-Djava.security.egd=file:/dev/./urandom\"'"

# Download and extract DHIS 2.28, start Tomcat
ansible localhost -m get_url -a "url=https://s3-eu-west-1.amazonaws.com/releases.dhis2.org/2.28/dhis.war dest=/var/lib/tomcat/webapps/ROOT.war owner=tomcat group=tomcat"
ansible localhost -m file -a "path=/var/lib/tomcat/webapps/ROOT state=directory owner=tomcat group=tomcat"
ansible localhost -m unarchive -a "src=/var/lib/tomcat/webapps/ROOT.war dest=/var/lib/tomcat/webapps/ROOT/ owner=tomcat group=tomcat"
systemctl start tomcat

# Configure and start Nginx
ansible localhost -m lineinfile -a "path='/etc/nginx/nginx.conf' insertafter='^[^#]\s+location\s+/\s+{' line='          proxy_pass  http://localhost:8080;' validate='nginx -c %s -t'"
ansible localhost -m lineinfile -a "path='/etc/nginx/nginx.conf' insertafter='^[^#]\s+proxy_pass\s+' line='          proxy_set_header  Host               \$http_host;' validate='nginx -c %s -t'"
ansible localhost -m lineinfile -a "path='/etc/nginx/nginx.conf' insertafter='^[^#]\s+proxy_set_header\s+Host\s+' line='          proxy_set_header  X-Forwarded-Proto  \$scheme;' validate='nginx -c %s -t'"
systemctl start nginx
