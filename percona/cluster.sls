# Copyright 2013 Hewlett-Packard Development Company, L.P.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
include:
  - percona
  - percona.client
  - percona.minion

/root/.my.cnf:
  file:
    - managed
    - source: salt://percona/templates/dotmy.cnf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/etc/mysql:
  file:
    - directory
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/etc/mysql/my.cnf:
  file:
    - managed
    - source: salt://percona/templates/my.cnf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        nodes: {{ salt['pillar.get']('percona:nodes', {}) }}
        bootstrap_cluster: false
    - require:
      - file: /etc/mysql
    - require_in:
      - pkg: percona-xtradb-cluster-server-5.6

/etc/mysql/debian.cnf:
  file:
    - managed
    - source: salt://percona/templates/debian.cnf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - require:
      - file: /etc/mysql
      - pkg: percona-xtradb-cluster-server-5.6
      - service: mysql

percona-preseed-root-password:
  debconf.set:
    - name: percona-xtradb-cluster-server-5.6
    - data:
        'percona-server-server/root_password': { 'type': 'password', 'value': '{{ salt['pillar.get']('percona:passwords:root', '') }}' }
        'percona-server-server/root_password_again': { 'type': 'password', 'value': '{{ salt['pillar.get']('percona:passwords:root', '') }}' }

percona-xtradb-cluster-server-5.6:
  pkg:
    - latest
    - require:
      - debconf: percona-preseed-root-password

mysql:
  service:
  - running
  - require:
    - pkg: percona-xtradb-cluster-server-5.6

mysql_user_debian_sys_maint:
  mysql_user:
    - present
    - name: debian-sys-maint
    - password: {{ salt['pillar.get']('percona:passwords:debian_sys_maint', '') }}
    - host: localhost
    - connection_unix_socket: /var/run/mysqld/mysqld.sock
    - connection_user: root
    - connection_pass: {{ salt['pillar.get']('percona:passwords:root', '') }}
    - connection_db: mysql
    - require:
      - service: mysql

mysql_user_salt:
  mysql_user:
    - present
    - name: salt
    - password: {{ salt['pillar.get']('percona:passwords:salt', '') }}
    - host: localhost
    - connection_unix_socket: /var/run/mysqld/mysqld.sock
    - connection_user: root
    - connection_pass: {{ salt['pillar.get']('percona:passwords:root', '') }}
    - connection_db: mysql
    - require:
      - service: mysql

mysql_grants_salt:
   mysql_grants:
    - present
    - grant: "ALL PRIVILEGES"
    - grant_option: "GRANT"
    - database: "*.*"
    - user: salt
    - host: localhost
    - connection_unix_socket: /var/run/mysqld/mysqld.sock
    - connection_user: root
    - connection_pass: {{ salt['pillar.get']('percona:passwords:root', '') }}
    - connection_db: mysql
    - require:
      - mysql_user: mysql_user_salt

mysql_user_xtrabackup:
  mysql_user:
    - present
    - name: xtrabackup
    - password: {{ salt['pillar.get']('percona:passwords:xtrabackup', '') }}
    - host: localhost
    - connection_unix_socket: /var/run/mysqld/mysqld.sock
    - connection_user: root
    - connection_pass: {{ salt['pillar.get']('percona:passwords:root', '') }}
    - connection_db: mysql
    - require:
      - service: mysql

mysql_grants_xtrabackup:
   mysql_grants:
    - present
    - grant: "RELOAD, LOCK TABLES, REPLICATION CLIENT"
    - database: "*.*"
    - user: xtrabackup
    - host: localhost
    - connection_unix_socket: /var/run/mysqld/mysqld.sock
    - connection_user: root
    - connection_pass: {{ salt['pillar.get']('percona:passwords:root', '') }}
    - connection_db: mysql
    - require:
      - mysql_user: mysql_user_xtrabackup
