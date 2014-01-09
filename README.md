# Percona Cluster State

Deploy process:

* The first node in the cluster MUST be provisioned with percona.cluster_bootstrap
* Then deploy the remaining nodes with percona.cluster
* Then circle back to the first node, and run percona.cluster
