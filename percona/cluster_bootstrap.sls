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
  - percona.cluster

exclude:
  - id: /etc/mysql/my.cnf

/etc/mysql/my.cnf-bootstrap:
  file:
    - managed
    - name: /etc/mysql/my.cnf
    - source: salt://percona/templates/my.cnf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        nodes: {{ salt['pillar.get']('percona:nodes', {}) }}
        bootstrap_cluster: true
    - require:
      - file: /etc/mysql
    - require_in:
      - pkg: percona-xtradb-cluster-server-5.6
