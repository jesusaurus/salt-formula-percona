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
{%- macro mysql_user(name, host, password, state='present') -%}
"mysql_user_{{ name }}_{{ host }}":
  mysql_user:
    - {{ state }}
    - name: "{{ name }}"
    - host: "{{ host }}"
    - password: "{{ password }}"
    - connection_unix_socket: /var/run/mysqld/mysqld.sock
    - connection_user: root
    - connection_pass: {{ salt['pillar.get']('percona:passwords:root', '') }}
    - connection_db: mysql
    - require:
      - service: mysql
{%- endmacro -%}

{%- macro mysql_database(name, state='present') -%}
mysql_database_{{ name }}:
  mysql_database:
    - {{ state }}
    - name: "{{ name }}"
    - connection_unix_socket: /var/run/mysqld/mysqld.sock
    - connection_user: root
    - connection_pass: {{ salt['pillar.get']('percona:passwords:root', '') }}
    - connection_db: mysql
    - require:
      - service: mysql
{%- endmacro -%}

{%- macro mysql_grant(user, host, database, grant='ALL PRIVILEGES', grant_option=False, state='present') -%}
"mysql_grants_{{ user }}_{{ host }}_{{ database }}":
   mysql_grants:
    - {{ state }}
    - user: "{{ user }}"
    - host: "{{ host }}"
    - database: "{{ database }}"
    - grant: "{{ grant }}"
    - grant_option: {{ grant_option }}
    - connection_unix_socket: /var/run/mysqld/mysqld.sock
    - connection_user: root
    - connection_pass: {{ salt['pillar.get']('percona:passwords:root', '') }}
    - connection_db: mysql
    - require:
      - mysql_user: "mysql_user_{{ user }}_{{ host }}"
{%- endmacro -%}

