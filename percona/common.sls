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
# Import the macros we use
{% from "percona/macros.sls" import mysql_user with context %}
{% from "percona/macros.sls" import mysql_database with context %}
{% from "percona/macros.sls" import mysql_grant with context %}

mysql:
  service:
  - running
  - require:
    - pkg: percona-server

########################
## General Configuration
/etc/mysql:
  file:
    - directory
    - user: root
    - group: root
    - mode: 755

/etc/mysql/my.cnf:
  file:
    - managed
    - source: salt://percona/templates/my.cnf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /etc/mysql
    - require_in:
      - pkg: percona-server

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
      - pkg: percona-server

/root/.my.cnf:
  file:
    - managed
    - source: salt://percona/templates/dotmy.cnf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 600

############################
## Required Users and Grants
{{ mysql_user("debian_sys_maint", "localhost", salt['pillar.get']('percona:passwords:debian_sys_maint', '')) }}

{{ mysql_user("root", "localhost", salt['pillar.get']('percona:passwords:root', '')) }}
{{ mysql_grant("root", "localhost", "*.*", grant_option=True) }}

{{ mysql_user("xtrabackup", "localhost", salt['pillar.get']('percona:passwords:xtrabackup', '')) }}
{{ mysql_grant("xtrabackup", "localhost", "*.*", grant='RELOAD, LOCK TABLES, REPLICATION CLIENT') }}

####################################
## Custom Users, Database and Grants
{% for name, database in salt['pillar.get']('percona:databases', {}).iteritems() %}
{{ mysql_database(name, state=database.get('state', 'present')) }}
{% endfor %}

{% for name, user in salt['pillar.get']('percona:users', {}).iteritems() -%}
{{ mysql_user(user.get("name", name), user.get("host", "localhost"), user.get("password", "")) }}
{% endfor %}

{% for grant in salt['pillar.get']('percona:grants', []) -%}
{{ mysql_grant(grant.get('user'), grant.get("host", "localhost"), grant.get("database", "*.*"), grant.get("grant", None)) }}
{% endfor %}
